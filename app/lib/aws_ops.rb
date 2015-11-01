require 'aws-sdk'

module AwsOps
  
  VPC = '172.32.0.0/16'
  ELB_NAME = 'ELB'
  ASG_WEB_NAME = 'web'
  ASG_WORKER_NAME = 'worker'
  ASG_ROLES = [ASG_WEB_NAME, ASG_WORKER_NAME]
  LOAD_BALANCED_ASGS = [ASG_WEB_NAME]
  AVAILABILITY_ZONES = ['eu-west-1a', 'eu-west-1b', 'eu-west-1c']
  KEYPAIR_NAME = 'eu_west_1'
  
  def ec2_client
    @@ec2_client ||= Aws::EC2::Client.new
  end
  
  def iam_client
    @@iam_client ||= Aws::IAM::Client.new
  end
  
  def elb_client
    @@elb_client ||= Aws::ElasticLoadBalancing::Client.new
  end
  
  def auto_scaling_client
    @@auto_scaling_client ||= Aws::AutoScaling::Client.new
  end
  
end