module AwsOps
  class Permanent # permanent infrastructure goes here - i.e. the resources that are created once and then never changed again: databases, subnets, ELBs, SGs, S3 buckets...
    
    extend AwsOps
    
    def self.db_name # make sure it matches database.yml
      "estiu_#{environment}"
    end
    
    def self.security_groups
      Hash.new{ raise }.merge({ # TODO - fetch from API. assume key names. especially important after introducing `environment`.
        port_443_public: 'sg-a68a3ac2',    
        port_80_public: "sg-e19e2985",
        port_80_vpc: "sg-fd9e2999",
        ssh: 'sg-ca9e29ae',
        smtp: 'sg-5abc313e'
      })
    end
    
    def self.security_groups_per_worker
      Hash.new{raise}.merge({
        ASG_WEB_NAME => [security_groups[:port_80_vpc], security_groups[:ssh]],
        ASG_WORKER_NAME => [security_groups[:ssh], security_groups[:smtp]]
      })
    end
    
    def self.https_elb_setup
      
        private_key_name = "private_key_#{environment}"
        csr_name = "csr_#{environment}"
        certificate_name = "certificate_#{environment}"
        
        iam_client.delete_server_certificate({server_certificate_name: certificate_name}) rescue Aws::IAM::Errors::NoSuchEntity
        
        `rm -f #{private_key_name}.pem #{csr_name}.pem #{certificate_name}.pem`
        
        `openssl genrsa -out #{private_key_name}.pem 2048`
        `openssl req -sha256 -new -key #{private_key_name}.pem -out #{csr_name}.pem -subj "/C=ES/ST=Barcelona/L=Barcelona/O=vemv/OU=vemv/CN=aws.vemv.net/emailAddress=vemv@vemv.net"`
        `openssl x509 -req -days 365 -in #{csr_name}.pem -signkey #{private_key_name}.pem -out #{certificate_name}.pem`
        
        server_certificate_id = nil
        
        begin
          
          server_certificate_id = iam_client.upload_server_certificate(
            server_certificate_name: certificate_name,
            certificate_body: File.read(File.join Rails.root, "#{certificate_name}.pem"),
            private_key: File.read(File.join Rails.root, "#{private_key_name}.pem")).
          server_certificate_metadata.arn
          
        rescue Aws::IAM::Errors::EntityAlreadyExists => e
          n = 10
          puts "#{e.class} - Sleeping #{n} seconds..."
          sleep n
          retry
        end
        
        `rm -f #{private_key_name}.pem #{csr_name}.pem #{certificate_name}.pem`
        
        server_certificate_id
        
    end
    
    def self.create_elb https=false
      
      dns_name = nil
      
      listeners = [
        {
          protocol: "HTTP",
          load_balancer_port: 80,
          instance_protocol: "HTTP",
          instance_port: 80
        }
      ]
      
      _security_groups = [security_groups[:port_80_public]]
      
      if https
        
        listeners <<
          {
            protocol: "HTTPS",
            load_balancer_port: 443,
            instance_protocol: "HTTP",
            instance_port: 80,
            ssl_certificate_id: https_elb_setup
          }
        
        _security_groups << security_groups[:port_443_public]
        
      end
      
      begin
        
        dns_name = elb_client.create_load_balancer({
          load_balancer_name: elb_name,
          listeners: listeners,
          security_groups: _security_groups,
          availability_zones: availability_zones,
          tags: [
            {
              key: 'environment',
              value: environment
            }
          ]
        }).dns_name
          
      rescue Aws::ElasticLoadBalancing::Errors::CertificateNotFound => e
        
        n = 10
        puts "#{e.class} - Sleeping #{n} seconds..."
        sleep n
        retry
        
      end

      health_path = Estiu::Application.health_path environment
      health_path = health_path[1..(health_path.size)] if health_path.start_with?('/')
      
      elb_client.configure_health_check({
        load_balancer_name: elb_name,
        health_check: {
          target: "HTTP:80/#{health_path}",
          interval: 7,
          timeout: 5,
          unhealthy_threshold: 2,
          healthy_threshold: 2
        }
      })
      
      elb_client.modify_load_balancer_attributes({
        load_balancer_name: elb_name,
        load_balancer_attributes: {
          connection_draining: {
            enabled: true,
            timeout: AwsOps::CONNECTION_DRAINING_TIMEOUT
          }
        }
      })
      
      if environment == 'staging'
        
        r53_client.change_resource_record_sets(
          hosted_zone_id: 'Z2Q23XVC6W99R2', # estiu.events
          change_batch: {
            changes: [
              {
                action: 'UPSERT',
                resource_record_set: {
                  name: 'staging.estiu.events.',
                  type: 'CNAME',
                  ttl: 600,
                  resource_records: [
                    {value: dns_name}
                  ]
                }
              }
            ]
          }
        )
        
      end
      
    end
    
    def self.delete_elbs
      `rm -f *.pem`
      names =
        elb_client.describe_load_balancers.load_balancer_descriptions.select{|elb|
          elb_client.describe_tags(load_balancer_names: [elb.load_balancer_name]).tag_descriptions[0].tags.detect{|tag|
            tag.key == 'environment' && tag.value == environment
          }
        }.
        map(&:load_balancer_name)
      names.each do |lb|
        elb_client.delete_load_balancer load_balancer_name: lb
      end
      names.any?
    end
    
    POSTGRES_SECURITY_GROUP = "postgresql"
    
    def find_or_create_postgres_security_group
      name = POSTGRES_SECURITY_GROUP
      existing = ec2_client.<FIND_BY_NAME>(name).first # XXX
      return existing.group_id if existing
      group_id = ec2_client.create_security_group({
        group_name: name,
        description: name
      }).group_id
      ec2_client.authorize_security_group_ingress({
        group_name: name,
        ip_protocol: "tcp",
        from_port: 5432,
        to_port: 5432,
        cidr_ip: "0.0.0.0/0"
      })
      group_id
    end
    
    def self.create_rds
      security_group_id = find_or_create_postgres_security_group
      username = base_dotenv_environment['POSTGRESQL_USERNAME']
      password = base_dotenv_environment['POSTGRESQL_PASSWORD']
      db_instance_identifier = base_dotenv_environment[AwsOps::RDS_INSTANCE_ID_KEY]
      
      instance = rds_client.create_db_instance({
        db_name: db_name,
        db_instance_identifier: db_instance_identifier,
        engine: 'postgres',
        db_instance_class: 'db.t2.micro',
        master_username: username,
        master_user_password: password,
        backup_retention_period: (environment == 'production' ? 90 : 0),
        allocated_storage: 8,
        vpc_security_group_ids: [security_group_id]
        # XXX needs multi-az option
      }).db_instance
      
      rds_client.wait_until :db_instance_available, db_instance_identifier: db_instance_identifier
      host = rds_client.describe_db_instances(db_instance_identifier: db_instance_identifier).db_instances.first.endpoint.address
      
      `echo "\nPOSTGRESQL_HOST=#{host}" >> .env.#{environment}`
      puts "ATTENTION! Your .env.#{environment} file has been appended one RDS-related entry (POSTGRESQL_HOST). Make sure to delete the old POSTGRESQL_HOST entry (if any)."
      
    end
    
    def self.delete_rds
      skip_final_snapshot = environment != 'production'
      opts = {
        db_instance_identifier: base_dotenv_environment[AwsOps::RDS_INSTANCE_ID_KEY],
        skip_final_snapshot: skip_final_snapshot
      }
      opts.merge!(final_db_snapshot_identifier: "final-snapshot-#{SecureRandom.hex}") unless skip_final_snapshot
      rds_client.delete_db_instance(opts)
    end
    
  end
end