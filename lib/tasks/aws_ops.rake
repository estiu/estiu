namespace :aws_ops do
  
  task create: :environment do
    AwsOps::Infrastructure.create!
  end
  
  task launch_worker: :environment do
    AwsOps::Infrastructure.launch_worker!
  end
  
  task update_env: :environment do
    AwsOps::S3.update_env_files
  end
  
  task delete: :environment do
    AwsOps::Infrastructure.delete!
  end
  
end
