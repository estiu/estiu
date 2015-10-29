class AwsOps
  
  def self.security_groups
    {
      port_80_public: "sg-e19e2985",
      port_80_vpc: "sg-fd9e2999"
    }
  end
  
  VPC = '172.32.0.0/16'
  ELB_NAME = 'ELB'
  ASG_NAME = 'ASG'
  LAUNCH_CONFIGURATION_NAME = "web"
  AVAILABILITY_ZONES = ['eu-west-1a', 'eu-west-1b', 'eu-west-1c']
  
  def self.create_elb
    client = Aws::ElasticLoadBalancing::Client.new
    client.create_load_balancer({
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
  end
  
  def self.create_asg
    client = Aws::AutoScaling::Client.new
    client.create_auto_scaling_group({
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
      create_elb && create_asg
    rescue Exception => e
      # TODO - destroy partially created resources (e.g. elb succeeds, asg fails.)
      raise e
    end
  end
  
end