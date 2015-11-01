class AwsOps::Capistrano
  
  extend AwsOps
  
  def self.deployable_ips role
    asg_instances = auto_scaling_client.describe_auto_scaling_groups(auto_scaling_group_names: [role]).auto_scaling_groups[0].instances
    ids = asg_instances.select{|i| i.health_status.upcase == "HEALTHY" }.map &:instance_id
    instances = ec2_client.describe_instances({filters: [{name: 'instance-id', values: ids}]}).reservations.map(&:instances).flatten
    ips = instances.select{|i| i.state.name == 'running' }.map(&:public_ip_address)
    
    fail "No deployable ips found (role: #{role})" if ips.size.zero?

    instances_info = ips.map{|ip|
      instance = instances.detect{|i| i.public_ip_address == ip }
      {instance_id: instance.instance_id, public_ip_address: instance.public_ip_address}
    }

    puts "Role #{role} - deploying #{ips.size} machines: #{instances_info}"
    
    ips.map {|ip| "ubuntu@#{ip}" }
    
  end
  
end