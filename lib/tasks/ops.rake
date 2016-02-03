def reset_state environment, silent=false
  AwsOps::Ec2.wait_until_all_instances_terminated
  AwsOps::SQS.drain_all_queues!
  command = "RAILS_ENV=#{environment} bundle exec rake db:drop db:create db:migrate"
  if silent
    `#{command}`
  else
    system(command) || fail
  end
end

namespace :ops do
  
  task update_env: :environment do
    AwsOps::S3.update_env_files
  end
  
  task seed: :environment do
    FG.create :campaign, :almost_fulfilled, starts_immediately: true, ends_at: 120.seconds.from_now
  end
  
  %i(production staging).each do |environment|
    
    namespace environment do
      
      task create: :environment do
        AwsOps.aws_ops_environment = environment
        AwsOps::Infrastructure.delete!
        reset_state environment
        AwsOps::Infrastructure.create!
      end
      
      task launch_worker: :environment do
        AwsOps.aws_ops_environment = environment
        AwsOps::Infrastructure.launch_worker!
      end
      
      task delete: :environment do
        AwsOps.aws_ops_environment = environment
        AwsOps::Infrastructure.delete!
        reset_state environment, :silent
      end
      
    end
    
  end
  
end
