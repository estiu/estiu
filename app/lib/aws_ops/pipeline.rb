class AwsOps::Pipeline
  
  extend AwsOps
  
  def self.unschedule_campaign_unfulfillment_check campaign_id
    name = id_for campaign_id
    data_pipeline_client.delete_pipeline({
      pipeline_id: name
    })
  end
  
  def self.schedule_campaign_unfulfillment_check campaign
    name = id_for campaign.id
    data_pipeline_client.create_pipeline({
      name: name,
      unique_id: name
    })
    data_pipeline_client.put_pipeline_definition({
      pipeline_id: name,
      pipeline_objects: [
        {
          id: 'Schedule',
          name: 'Schedule',
          fields: [
            {key: 'type', string_value: 'Schedule'},
            {key: 'occurrences', string_value: '1'},
            {key: 'startDateTime', string_value: campaign.ends_at.iso8601},
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
            {key: 'securityGroupIds', string_value: AwsOps::Infrastructure.security_groups_per_worker[AwsOps::ASG_WORKER_NAME]}
          ]
        }
      ]
    })
  end
  
  def self.id_for c
    "campaign_fulfillment_check_#{c}"
  end
  
end