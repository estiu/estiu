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
      
      task deploy: :update_env do
        AwsOps.deploy!
        AwsOps::Transient.put_old_asgs_in_standby!
        puts "Type 'OK' to confirm that the deploy was performed correctly, deleting the old ASGs accordingly. Else press Enter."
        if gets.downcase.include?('ok')
          AwsOps::Transient.delete_old_asgs!
        elsif
          
          puts "If the deploy didn't go OK:"
          puts "do a git reset --hard to the commit matching to the old ASG (it is essential to go back to a matching SHA). Then run the `ops:#{environment}:rollback` task."
          
          puts "If the deploy went OK:"
          puts "Run the `ops:#{environment}:delete_old_asgs` task immediately."
          
        end
      end
      
      task delete_old_asgs: :update_env do
        AwsOps::Transient.delete_old_asgs!
      end
      
      task rollback: :update_env do
        AwsOps::Transient.put_current_asgs_in_service!
        AwsOps::Transient.delete_old_asgs!
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
