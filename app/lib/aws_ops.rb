require 'aws-sdk'

module AwsOps
  
  %w(AWS_ACCESS_KEY_ID AWS_ACCESS_KEY AWS_SECRET_ACCESS_KEY AWS_SECRET_KEY).each{|a| ENV.delete a } # prevent any possible pollution
  
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
  UPLOADS_BUCKET = "events-uploads-#{Rails.env}"
  
  def environment
    (self.aws_ops_environment || Rails.env).to_s
  end
  
  def credentials
    if ENV['CODESHIP'].present?
      Hash[
        %w(AWS_ACCESS_KEY_ID AWS_ACCESS_KEY AWS_SECRET_ACCESS_KEY AWS_SECRET_KEY).map{|k|
          [k, ENV[k]]
        }
      ]
    else
      Dotenv::Environment.new(".aws_credentials.#{environment}").to_h
    end.symbolize_keys
  end
  
  def region 
    values = { # http://www.cloudping.info
      'production' => 'eu-central-1', # production should be ireland. will switch with https://trello.com/c/Gcs8Svj4/181-use-separate-aws-accounts-for-each-env 
      'staging' => 'eu-west-1',
      'development' => 'us-east-1',
      'test' => 'us-west-2'
    }
    raise "no environments should share the same region" if values.keys.uniq.size != values.values.uniq.size
    Hash.new{raise}.merge(values)[environment]
  end
  
  def ec2_client
    @@ec2_client ||= Aws::EC2::Client.new(credentials)
  end
  
  def s3_client
    @@s3_client ||= Aws::S3::Client.new(credentials)
  end
  
  def iam_client
    @@iam_client ||= Aws::IAM::Client.new(credentials)
  end
  
  def elb_client
    @@elb_client ||= Aws::ElasticLoadBalancing::Client.new(credentials)
  end
  
  def auto_scaling_client
    @@auto_scaling_client ||= Aws::AutoScaling::Client.new(credentials)
  end
  
  def data_pipeline_client
    @@data_pipeline_client ||= Aws::DataPipeline::Client.new(credentials)
  end
  
  def sqs_client
    @@sqs_client ||= Aws::SQS::Client.new(credentials)
  end
  
  def r53_client
    @@r53_client ||= Aws::Route53::Client.new(credentials)
  end
  
  def elb_name
    "#{ELB_NAME}-#{environment}"
  end
  
end