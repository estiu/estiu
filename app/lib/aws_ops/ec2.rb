class AwsOps::Ec2
  
  extend AwsOps
  
  def self.wait_until_all_instances_terminated # XXX should query by environment
    return unless AwsOps::Ec2.ec2_client.describe_instances.reservations[0] # don't wait forever if there's nothing to wait
    ec2_client.wait_until :instance_terminated # query all possible instances regardless of their state.
  end
  
end