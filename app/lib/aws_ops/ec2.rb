class AwsOps::Ec2
  
  extend AwsOps
  
  def self.wait_until_all_instances_terminated # XXX should query by environment
    ec2_client.wait_until :instance_terminated # query all possible instances regardless of their state.
  end
  
end