def reset_state silent=false
  # TODO clear Data Pipeline
  AwsOps::SQS.drain_all_queues!
  command = 'RAILS_ENV=production bundle exec rake db:drop db:create db:migrate'
  if silent
    `#{command}`
  else
    system command || fail
  end
end

namespace :aws_ops do
  
  task create: :environment do
    AwsOps::Infrastructure.delete!
    # TODO wait for instances to completely shut down
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
    reset_state :silent
  end
  
end
