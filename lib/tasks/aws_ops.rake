def reset_state
  AwsOps::SQS.drain_all_queues!
  system 'RAILS_ENV=production bundle exec rake db:drop db:create db:migrate' || fail
end

namespace :aws_ops do
  
  task create: :environment do
    AwsOps::Infrastructure.delete!
    reset_state
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
    reset_state
  end
  
end
