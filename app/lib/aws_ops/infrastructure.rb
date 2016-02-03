module AwsOps
  class Infrastructure
    
    extend AwsOps
    
    def self.security_groups
      Hash.new{ raise }.merge({ # TODO - fetch from API. assume key names. especially important after introducing `environment`.
        port_443_public: 'sg-a68a3ac2',    
        port_80_public: "sg-e19e2985",
        port_80_vpc: "sg-fd9e2999",
        ssh: 'sg-ca9e29ae',
        smtp: 'sg-5abc313e'
      })
    end
    
    def self.delete_elbs # XXX elb_client.describe_load_balancers.select{|x| x.tags.environment == environment }
      `rm -f *.pem`
      names = elb_client.describe_load_balancers.load_balancer_descriptions.map &:load_balancer_name
      names.each do |lb|
        elb_client.delete_load_balancer load_balancer_name: lb
      end
      names.any?
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
        
        elb_client.create_load_balancer({
          load_balancer_name: elb_name,
          listeners: listeners,
          security_groups: _security_groups,
          availability_zones: AVAILABILITY_ZONES,
          tags: [
            {
              key: 'environment',
              value: environment
            }
          ]
        })
          
      rescue Aws::ElasticLoadBalancing::Errors::CertificateNotFound => e
        
        n = 10
        puts "#{e.class} - Sleeping #{n} seconds..."
        sleep n
        retry
        
      end
      
      elb_client.configure_health_check({
        load_balancer_name: elb_name,
        health_check: {
          target: "HTTP:80/",
          interval: 7,
          timeout: 5,
          unhealthy_threshold: 2,
          healthy_threshold: 2
        }
      })
      
      # XXX upate cloudflare to cname the load balancer's subdomain, on a per-env basis
      
    end
    
    def self.clean_ubuntu_ami size
      # I think all these sizes are fine with the same AMI, but larger need a different ubuntu image.
      ami1 = 'ami-47a23a30'
      Hash.new { raise }.merge({
        't2.micro' => ami1,
        't2.small' => ami1,
        't2.medium' => ami1
      })[size]
    end
    
    def self.latest_ami_object role, size
      latest = ec2_client.describe_images(owners: ['self']).images.
        select{|image|
          image.tags.detect{|tag|
            tag.key == 'type' && tag.value == role.to_s
          }
        }.sort {|a, b|
          DateTime.iso8601(a.creation_date) <=> DateTime.iso8601(b.creation_date)
        }.
        last
      if latest
        latest
      else
        if role.to_s == BASE_IMAGE_NAME
          Struct.new(:image_id).new(clean_ubuntu_ami size)
        else
          latest_ami BASE_IMAGE_NAME, size
        end
      end

    end
    
    def self.latest_ami role=BASE_IMAGE_NAME, size
      latest_ami_object(role, size).image_id
    end
    
    def self.delete_amis newer_too=false
      IMAGE_TYPES.each do |role|
        images = ec2_client.describe_images(owners: ['self']).images.
        select{|image|
          image.tags.detect{|tag|
            tag.key == 'type' && tag.value == role.to_s
          }
        }.sort {|a, b|
          DateTime.iso8601(a.creation_date) <=> DateTime.iso8601(b.creation_date)
        }
        target = newer_too ? images : images[0...(images.size - 1)]
        target.each do |image|
          puts "Deregistering #{image.image_id}"
          ec2_client.deregister_image({image_id: image.image_id})
          ec2_client.delete_snapshot({snapshot_id: image.block_device_mappings.detect(&:ebs).ebs.snapshot_id})
        end
      end
    end
    
    
    def self.delete_launch_configurations # XXX per-env
      names = auto_scaling_client.describe_launch_configurations.launch_configurations.map &:launch_configuration_name
      names.each do |name|
        auto_scaling_client.delete_launch_configuration launch_configuration_name: name
      end
      names.any?
    end
    
    def self.security_groups_per_worker
      Hash.new{raise}.merge({
        ASG_WEB_NAME => [security_groups[:port_80_vpc], security_groups[:ssh]],
        ASG_WORKER_NAME => [security_groups[:ssh], security_groups[:smtp]]
      })
    end
    
    # LCs don't support tags.
    # anyway, LCs don't support updating the AMI id, so the current setup is unfit for production.z
    def self.create_launch_configurations roles=ASG_ROLES
      roles.each do |role|
        auto_scaling_client.create_launch_configuration({
          launch_configuration_name: role,
          image_id: latest_ami(role, PRODUCTION_SIZE),
          instance_type: AwsOps::PRODUCTION_SIZE,
          security_groups: security_groups_per_worker[role],
          key_name: KEYPAIR_NAME,
          iam_instance_profile: Iam.instance_profile_arn
        })
      end
    end
    
    def self.delete_asgs # XXX per env
      names = auto_scaling_client.describe_auto_scaling_groups.auto_scaling_groups.map &:auto_scaling_group_name
      names.each do |name|
        auto_scaling_client.delete_auto_scaling_group auto_scaling_group_name: name, force_delete: true
      end
      names.any?
    end
    
    def self.create_asgs roles=ASG_ROLES
      roles.each do |asg_name|
        ami = latest_ami_object asg_name, AwsOps::PRODUCTION_SIZE
        commit = ami.tags.detect{|t|t.key == 'commit'}.try(&:value)
        opts = {
          auto_scaling_group_name: "#{asg_name} #{SecureRandom.hex 6}",
          launch_configuration_name: asg_name,
          min_size: 1,
          max_size: 1,
          availability_zones: AVAILABILITY_ZONES,
          tags: [
            {
              key: 'commit',
              value: commit
            },
            {
              key: 'environment',
              value: environment
            }
          ]
        }
        opts.merge!({load_balancer_names: [elb_name]}) if LOAD_BALANCED_ASGS.include?(asg_name)
        auto_scaling_client.create_auto_scaling_group(opts)
      end
    end
    
    def self.create!
      begin
        create_elb
        create_launch_configurations
        create_asgs
        puts "AWS infrastructure succesfully created."
      rescue Exception => e
        puts "An error ocurred."
        delete!
        raise e
      end
    end
    
    def self.launch_worker!
      delete!
      begin
        create_launch_configurations [ASG_WORKER_NAME]
        create_asgs [ASG_WORKER_NAME]
        puts "Worker succesfully launched."
      rescue Exception => e
        puts "An error ocurred."
        delete!
        raise e
      end
    end
    
    def self.delete!
      puts "Deleting infrastructure..."
      delete_elbs
      delete_asgs
      delete_launch_configurations
    end
    
  end
end