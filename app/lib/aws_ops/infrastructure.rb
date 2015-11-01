module AwsOps
  class Infrastructure
    
    extend AwsOps
    
    def self.security_groups
      Hash.new{ raise }.merge({ # TODO - fetch from API. assume key names
        port_443_public: 'sg-a68a3ac2',    
        port_80_public: "sg-e19e2985",
        port_80_vpc: "sg-fd9e2999",
        ssh: 'sg-ca9e29ae'
      })
    end
    
    def self.delete_elbs
      names = elb_client.describe_load_balancers.load_balancer_descriptions.map &:load_balancer_name
      names.each do |lb|
        elb_client.delete_load_balancer load_balancer_name: lb
      end
      names.any?
    end
    
    def self.create_elb
      
      private_key_name = 'private_key'
      csr_name = 'csr'
      certificate_name = 'certificate'
      
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
      
      begin
        
        elb_client.create_load_balancer({
          load_balancer_name: ELB_NAME,
          listeners: [
            {
              protocol: "HTTP",
              load_balancer_port: 80,
              instance_protocol: "HTTP",
              instance_port: 80
            },
            {
              protocol: "HTTPS",
              load_balancer_port: 443,
              instance_protocol: "HTTP",
              instance_port: 80,
              ssl_certificate_id: server_certificate_id
            }
          ],
          security_groups: [security_groups[:port_80_public], security_groups[:port_443_public]],
          availability_zones: AVAILABILITY_ZONES
          
        })
          
      rescue Aws::ElasticLoadBalancing::Errors::CertificateNotFound => e
        n = 10
        puts "#{e.class} - Sleeping #{n} seconds..."
        sleep n
        retry
      end
      
      elb_client.configure_health_check({
        load_balancer_name: ELB_NAME,
        health_check: {
          target: "HTTP:80/",
          interval: 7,
          timeout: 5,
          unhealthy_threshold: 2,
          healthy_threshold: 2
        }
      })
      
    end
    
    def self.latest_ami role
      # ec2_client.describe_images.filter('web').latest.id
      {
        ASG_WEB_NAME => 'ami-05c31c76',
        ASG_WORKER_NAME => 'ami-8114cbf2'
      }[role]
    end
    
    def self.delete_launch_configurations
      names = auto_scaling_client.describe_launch_configurations.launch_configurations.map &:launch_configuration_name
      names.each do |name|
        auto_scaling_client.delete_launch_configuration launch_configuration_name: name
      end
      names.any?
    end
    
    def self.create_launch_configurations
      security_groups_per_worker = {
        ASG_WEB_NAME => [security_groups[:port_80_vpc], security_groups[:ssh]],
        ASG_WORKER_NAME => [security_groups[:ssh]]
      }
      ASG_ROLES.each do |role|
        auto_scaling_client.create_launch_configuration({
          launch_configuration_name: role,
          image_id: latest_ami(role),
          instance_type: 't2.micro',
          security_groups: security_groups_per_worker[role],
          key_name: KEYPAIR_NAME
        })
      end
    end
    
    def self.delete_asgs
      names = auto_scaling_client.describe_auto_scaling_groups.auto_scaling_groups.map &:auto_scaling_group_name
      names.each do |name|
        auto_scaling_client.delete_auto_scaling_group auto_scaling_group_name: name, force_delete: true
      end
      names.any?
    end
    
    def self.create_asgs
      [ASG_WEB_NAME, ASG_WORKER_NAME].each do |asg_name|
        opts = {
          auto_scaling_group_name: asg_name,
          launch_configuration_name: asg_name,
          min_size: 1,
          max_size: 1,
          availability_zones: AVAILABILITY_ZONES
        }
        opts.merge!({load_balancer_names: [ELB_NAME]}) if LOAD_BALANCED_ASGS.include?(asg_name)
        auto_scaling_client.create_auto_scaling_group(opts)
      end
    end
    
    def self.create!
      delete!
      begin
        create_elb
        create_launch_configurations
        create_asgs
      rescue Exception => e
        delete!
        raise e
      end
    end
    
    def self.delete!
      delete_elbs
      delete_asgs
      delete_launch_configurations
    end
    
  end
end