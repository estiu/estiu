class AwsOps::Pipeline
  
  extend AwsOps
  
  def self.unschedule_campaign_unfulfillment_check campaign_id
    campaign = Campaign.find campaign_id
    id = campaign.unfulfillment_check_id
    Rails.logger.info "Deleting pipeline with id #{id}..."
    data_pipeline_client.delete_pipeline({pipeline_id: id})
    Rails.logger.info "Deleted pipeline with id #{id}."
  end
  
  def self.schedule_campaign_unfulfillment_check campaign, test=false
    
    name = test ? SecureRandom.hex : id_for(campaign.id)
    
    id = data_pipeline_client.create_pipeline({
      name: name,
      unique_id: name
    }).pipeline_id
    
    output = data_pipeline_client.put_pipeline_definition({
      pipeline_id: id,
      pipeline_objects: [
        {
          id: 'Default',
          name: 'Default',
          fields: [
            {key: 'pipelineLogUri', string_value: 's3://events-datapipeline'},
            {key: 'failureAndRerunMode', string_value: 'cascade'},
            {key: 'role', string_value: 'DataPipelineDefaultRole'},
            {key: 'resourceRole', string_value: 'DataPipelineDefaultResourceRole'},
            {key: 'schedule', ref_value: 'Schedule'},
            {key: 'scheduleType', string_value: 'cron'}
          ]
        },
        {
          id: 'Schedule',
          name: 'Schedule',
          fields: [
            {key: 'type', string_value: 'Schedule'},
            {key: 'occurrences', string_value: '1'},
            {key: 'startDateTime', string_value: (test ? 90.seconds.from_now : campaign.ends_at).utc.iso8601.split("Z")[0]},
            {key: 'period', string_value: '3 years'} # doesn't matter given the occurrence value of 1.
          ]
        },
        {
          id: 'Ec2Resource',
          name: 'Ec2Resource',
          fields: [
            {key: 'type', string_value: 'Ec2Resource'},
            {key: 'imageId', string_value: AwsOps::Infrastructure.latest_ami(AwsOps::PIPELINE_IMAGE_NAME, AwsOps::PRODUCTION_SIZE)},
            {key: 'instanceType', string_value: AwsOps::PRODUCTION_SIZE},
            {key: 'keyPair', string_value: AwsOps::KEYPAIR_NAME},
            {key: 'terminateAfter', string_value: '1 hour'},
            {key: 'runAsUser', string_value: AwsOps::USERNAME},
            {key: 'securityGroupIds', string_value: AwsOps::Infrastructure.security_groups_per_worker[AwsOps::ASG_WORKER_NAME].join(',')}
          ]
        },
        {
          id: 'ShellCommandActivity',
          name: 'ShellCommandActivity',
          fields: [
            {key: 'type', string_value: 'ShellCommandActivity'},
            {key: 'command', string_value: (test ? 'echo 42' : 'set -e; cd ~/events && git pull && bundle --without development test --path vendor/bundle && ruby bin/fetch_env.rb && bundle exec rake mark_unfulfilled_at')},
            {key: 'runsOn', ref_value: 'Ec2Resource'}
          ]
        }
      ]
    })
    
    if output.errored
      raise StandardError.new("validation_errors: #{output.validation_errors}")
      data_pipeline_client.delete_pipeline({pipeline_id: id})
    else
      Rails.logger.info "Activating pipeline with id #{id}..."
      data_pipeline_client.activate_pipeline({pipeline_id: id})
      campaign.update_column :unfulfillment_check_id, id unless test
      Rails.logger.info "Activated pipeline with id #{id}."
    end
    
  end
  
  def self.id_for c
    "campaign_fulfillment_check_#{c}"
  end
  
end