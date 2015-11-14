class AwsOps::Pipeline
  
  extend AwsOps
  
  def self.unschedule_campaign_unfulfillment_check campaign_id
    campaign = Campaign.find campaign_id
    id = campaign.unfulfillment_check_id
    Rails.logger.info "Deleting pipeline with id #{id}..."
    data_pipeline_client.delete_pipeline({pipeline_id: id})
    Rails.logger.info "Deleted pipeline with id #{id}."
  end
  
  def self.schedule_campaign_unfulfillment_check campaign
    
    name = id_for campaign.id
    
    id = data_pipeline_client.create_pipeline({
      name: name,
      unique_id: name
    }).pipeline_id
    
    output = data_pipeline_client.put_pipeline_definition({
      pipeline_id: id,
      pipeline_objects: [
        {
          id: 'Schedule',
          name: 'Schedule',
          fields: [
            {key: 'type', string_value: 'Schedule'},
            {key: 'occurrences', string_value: '1'},
            {key: 'startDateTime', string_value: campaign.ends_at.utc.iso8601.split("Z")[0]},
            {key: 'period', string_value: '3 years'} # doesn't matter given the occurrence value of 1.
          ]
        },
        {
          id: 'Ec2Resource',
          name: 'Ec2Resource',
          fields: [
            {key: 'type', string_value: 'Ec2Resource'},
            {key: 'imageId', string_value: AwsOps::Infrastructure.latest_ami(AwsOps::ASG_WORKER_NAME, AwsOps::PRODUCTION_SIZE)},
            {key: 'instanceType', string_value: AwsOps::PRODUCTION_SIZE},
            {key: 'keyPair', string_value: AwsOps::KEYPAIR_NAME},
            {key: 'runAsUser', string_value: AwsOps::USERNAME},
            {key: 'role', string_value: 'DataPipelineDefaultRole'},
            {key: 'resourceRole', string_value: 'events'},
            {key: 'schedule', ref_value: 'Schedule'},
            {key: 'securityGroupIds', string_value: AwsOps::Infrastructure.security_groups_per_worker[AwsOps::ASG_WORKER_NAME].join(',')}
          ]
        },
        {
          id: 'ShellCommandActivity',
          name: 'ShellCommandActivity',
          fields: [
            {key: 'type', string_value: 'ShellCommandActivity'},
            {key: 'command', string_value: 'echo 42'},
            {key: 'runsOn', ref_value: 'Ec2Resource'},
            {key: 'schedule', ref_value: 'Schedule'}
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
      campaign.update_column :unfulfillment_check_id, id
      Rails.logger.info "Activated pipeline with id #{id}."
    end
    
  end
  
  def self.id_for c
    "campaign_fulfillment_check_#{c}"
  end
  
end