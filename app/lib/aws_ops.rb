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
  KEYPAIR_NAME = 'eu_west_1'
  USERNAME = 'ec2-user'
  BUILD_SIZE = 't2.micro'
  PRODUCTION_SIZE = 't2.micro'
  UPLOADS_BUCKET = "estiu-uploads-#{Rails.env}"
  SCALE_OUT_SUFFIX = ' - scale out'
  SCALE_IN_SUFFIX = ' - scale in'
  CONNECTION_DRAINING_TIMEOUT = 30
  ESTIMATED_INIT_TIME = 210 # 3 minutes and half.
  RDS_INSTANCE_ID_KEY = 'RDS_INSTANCE_ID'
  
  def environment
    (self.aws_ops_environment || Rails.env).to_s
  end
  
  def credentials # the AWS API expects the aws_access_key and aws_secret_key key names, in downcase; no other names must be used.
    result = 
      if ENV['CODESHIP'].present?
        Hash[
          %w(access_key_id secret_access_key).map{|k|
            [k, ENV.fetch(k)]
          }
        ]
      else
        Dotenv::Environment.new(".aws_credentials.#{environment}").to_h
      end.symbolize_keys
    Hash.new{raise}.merge(result).merge(region: region)
  end
  
  def base_dotenv_environment
    @@base_dotenv_environment ||= Dotenv::Environment.new(".env.#{environment}").to_h
  end
  
  def region 
    values = { # http://www.cloudping.info
      'production' => 'us-east-1', # production should be ireland. will switch with https://trello.com/c/Gcs8Svj4/181-use-separate-aws-accounts-for-each-env 
      'staging' => 'eu-west-1', # eu-central-1 has no Data Pipeline.
      'development' => 'us-west-2',
      'test' => 'us-west-1' # us-west-1 has no Data Pipeline.
    }
    raise "no environments should share the same region" if values.keys.uniq.size != values.values.uniq.size
    Hash.new{raise}.merge(values)[environment]
  end
  
  def availability_zones
    # each region has 2-4 AZs. Discoverable with `aws ec2 describe-availability-zones --region us-west-2`
    @@availability_zones ||= ec2_client.describe_availability_zones.availability_zones.map(&:zone_name)
  end
  
  def current_commit
    `git rev-parse HEAD`.split("\n")[0]
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
  
  def cloudwatch_client
    @@cloudwatch_client ||= Aws::CloudWatch::Client.new(credentials)
  end

  def rds_client
    @@rds_client ||= Aws::RDS::Client.new(credentials)
  end
  
  def elb_name
    "#{ELB_NAME}-#{environment}"
  end
  
  def self.create!
    begin
      AwsOps::Permanent.create_elb
      AwsOps::Permanent.create_rds
      puts "Permanent infrastructure succesfully created."
      puts "Now you must rebuild non-base images so the new dotfiles are picked up."
    rescue Exception => e
      puts "An error ocurred."
      delete_permanent!
      raise e
    end
  end
  
  def self.deploy!
    AwsOps::SQS.ensure_queues_created
    AwsOps::Transient.create_launch_configurations
    AwsOps::Transient.create_asgs
    AwsOps::Transient.setup_metrics_for_asgs
    puts "Successfully created new ASGs."
  end
  
  def self.confirm
    STDIN.gets.downcase.include?('ok')
  end
  
  def self.delete_transient! silent=false
    puts "Deleting transient infrastructure..." unless silent
    AwsOps::Transient.delete_asgs
    AwsOps::Transient.delete_launch_configurations
    puts "Delete transient infrastructure." unless silent
  end
  
  def self.delete_permanent!
    
    delete_transient! :silent
    
    AwsOps::Permanent.delete_elbs
    # delete SGs, S3 buckets, etc
    
    puts "Deleted permanent infrastructure."
    
    if ::AwsOps::Permanent.environment == 'production'
      puts "Won't drop the production database. Do manually if really needed."
    else
      puts "Deleting RDS instances / data..."
      AwsOps::Permanent.delete_rds
      puts "Deleted RDS instances / data."
    end
    
  end
  
end