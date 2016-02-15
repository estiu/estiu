def reset_state environment, silent=false
  puts "Resetting state..."
  AwsOps::Ec2.wait_until_all_instances_terminated
  AwsOps::Pipeline::delete_all_pipelines!
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
    FG.create :campaign, :almost_fulfilled, campaign_draft: FG.create(:campaign_draft, :published, starts_immediately: true, ends_at: 1.hours.from_now, visibility: CampaignDraft::APP_VISIBILITY)
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
        AwsOps.delete!
        reset_state environment
        AwsOps.create!
      end
      
      task launch_worker: :update_env do
        AwsOps.launch_worker!
      end
      
      task delete: :update_env do
        AwsOps.delete!
        reset_state environment, :silent
      end
      
    end
    
  end
  
end
