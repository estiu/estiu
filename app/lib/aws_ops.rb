require 'aws-sdk'

module AwsOps
  
  VPC = '172.32.0.0/16'
  ELB_NAME = 'ELB'
  BASE_IMAGE_NAME = 'base'
  ASG_WEB_NAME = 'web'
  ASG_WORKER_NAME = 'worker'
  ASG_ROLES = [ASG_WEB_NAME, ASG_WORKER_NAME]
  LOAD_BALANCED_ASGS = [ASG_WEB_NAME]
  AVAILABILITY_ZONES = ['eu-west-1a', 'eu-west-1b', 'eu-west-1c']
  KEYPAIR_NAME = 'eu_west_1'
  USERNAME='ubuntu'
  CI_SIZE='t2.medium'
  PRODUCTION_SIZE='t2.micro'
  REGION='eu-west-1'
  
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
  
  def data_pipeline_client
    @@data_pipeline_client ||= Aws::DataPipeline::Client.new
  end
  
end