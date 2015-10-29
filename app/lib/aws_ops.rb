class AwsOps
  
  def self.security_groups
    {
      port_80_public: "sg-e19e2985",
      port_80_vpc: "sg-fd9e2999",
      ssh: 'sg-ca9e29ae'
    }
  end
  
  VPC = '172.32.0.0/16'
  ELB_NAME = 'ELB'
  ASG_NAME = 'web'
  LAUNCH_CONFIGURATION_NAME = "web"
  AVAILABILITY_ZONES = ['eu-west-1a', 'eu-west-1b', 'eu-west-1c']
  KEYPAIR_NAME = 'eu_west_1'
  
  def self.delete_elbs
    names = elb_client.describe_load_balancers.load_balancer_descriptions.map &:load_balancer_name
    names.each do |lb|
      elb_client.delete_load_balancer load_balancer_name: lb
    end
    names.any?
  end
  
  def self.create_elb
    elb_client.create_load_balancer({
      load_balancer_name: ELB_NAME,
      listeners: [
        {
          protocol: "HTTP",
          load_balancer_port: 80,
          instance_protocol: "HTTP",
          instance_port: 80
        }
      ],
      security_groups: [security_groups[:port_80_public]],
      availability_zones: AVAILABILITY_ZONES
    })
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
  
  def self.create_ami
    # deregister existing amis, volumes/snapshots
    # invoke packer
  end
  
  def self.latest_ami
    # ec2_client.describe_images.filter('web').latest.id
    'ami-05c31c76'
  end
  
  def self.delete_launch_configurations
    names = auto_scaling_client.describe_launch_configurations.launch_configurations.map &:launch_configuration_name
    names.each do |name|
      auto_scaling_client.delete_launch_configuration launch_configuration_name: name
    end
    names.any?
  end
  
  def self.create_launch_configurations
    auto_scaling_client.create_launch_configuration({
      launch_configuration_name: LAUNCH_CONFIGURATION_NAME,
      image_id: latest_ami,
      instance_type: 't2.micro',
      security_groups: [security_groups[:port_80_vpc], security_groups[:ssh]],
      key_name: KEYPAIR_NAME
    })
  end
  
  def self.delete_asgs
    names = auto_scaling_client.describe_auto_scaling_groups.auto_scaling_groups.map &:auto_scaling_group_name
    names.each do |name|
      auto_scaling_client.delete_auto_scaling_group auto_scaling_group_name: name, force_delete: true
    end
    names.any?
  end
  
  def self.create_asg
    auto_scaling_client.create_auto_scaling_group({
      auto_scaling_group_name: ASG_NAME,
      launch_configuration_name: LAUNCH_CONFIGURATION_NAME,
      min_size: 1,
      max_size: 1,
      load_balancer_names: [ELB_NAME],
      availability_zones: AVAILABILITY_ZONES
    })
  end
  
  def self.create!
    begin
      create_elb
      create_launch_configurations
      create_asg
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
  
  def self.ec2_client
    @@ec2_client ||= Aws::EC2::Client.new
  end
  
  def self.elb_client
    @@elb_client ||= Aws::ElasticLoadBalancing::Client.new
  end
  
  def self.auto_scaling_client
    @@auto_scaling_client ||= Aws::AutoScaling::Client.new
  end
  
end