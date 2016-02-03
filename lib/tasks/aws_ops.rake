def reset_state silent=false
  AwsOps::Ec2.wait_until_all_instances_terminated
  AwsOps::SQS.drain_all_queues!
  command = 'RAILS_ENV=production bundle exec rake db:drop db:create db:migrate'
  if silent
    `#{command}`
  else
    system(command) || fail
  end
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
    reset_state :silent
  end
  
  task seed: :environment do
    FG.create :campaign, :almost_fulfilled, starts_immediately: true, ends_at: 120.seconds.from_now
  end
  
end
