def reset_state environment, silent=false
  puts "Resetting state..."
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
  
  task seed: :environment do
    FG.create :campaign, :almost_fulfilled, starts_immediately: true, ends_at: 120.seconds.from_now
  end
  
  %i(production staging).each do |environment|
    
    task environment => :environment do
      AwsOps.aws_ops_environment = environment
    end
    
    namespace environment do
      
      task update_env: environment do
        AwsOps::S3.update_env_files
      end
      
      task create: :update_env do
        AwsOps::Infrastructure.delete!
        reset_state environment
        AwsOps::Infrastructure.create!
      end
      
      task launch_worker: :update_env do
        AwsOps::Infrastructure.launch_worker!
      end
      
      task delete: :update_env do
        AwsOps::Infrastructure.delete!
        reset_state environment, :silent
      end
      
    end
    
  end
  
end
