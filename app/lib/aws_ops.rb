class AwsOps
  
  def self.security_groups
    {
      port_80: "sg-b39522d7"
    }
  end
  
  ELB_NAME = 'ELB'
  ASG_NAME = 'ASG'
  LAUNCH_CONFIGURATION_NAME = "webCopy"
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
          instance_port: 3000
        }
      ],
      security_groups: [security_groups[:port_80]],
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
  
end