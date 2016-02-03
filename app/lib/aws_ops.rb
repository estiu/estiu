require 'aws-sdk'

module AwsOps
  
  mattr_accessor :aws_ops_environment
  
  VPC = '172.32.0.0/16'
  ELB_NAME = 'ELB'
  BASE_IMAGE_NAME = 'base'
  PIPELINE_IMAGE_NAME = 'pipeline'
  ASG_WEB_NAME = 'web'
  ASG_WORKER_NAME = 'worker'
  IMAGE_TYPES = [BASE_IMAGE_NAME, ASG_WEB_NAME, ASG_WORKER_NAME, PIPELINE_IMAGE_NAME]
  ASG_ROLES = [ASG_WEB_NAME, ASG_WORKER_NAME]
  LOAD_BALANCED_ASGS = [ASG_WEB_NAME]
  AVAILABILITY_ZONES = ['eu-west-1a']
  KEYPAIR_NAME = 'eu_west_1'
  USERNAME = 'ec2-user'
  BUILD_SIZE = 't2.micro'
  PRODUCTION_SIZE = 't2.micro'
  REGION = 'eu-west-1'
  UPLOADS_BUCKET = "events-uploads-#{Rails.env}"
  
  def ec2_client
    @@ec2_client ||= Aws::EC2::Client.new
  end
  
  def s3_client
    @@s3_client ||= Aws::S3::Client.new
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
  
  def sqs_client
    @@sqs_client ||= Aws::SQS::Client.new
  end
  
  def environment
    self.aws_ops_environment || fail("environment (production/staging) not set")
  end
  
  def elb_name
    "#{ELB_NAME}-#{environment}"
  end
  
end