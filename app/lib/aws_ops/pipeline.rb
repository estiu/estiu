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
          fields: {
            type: 'Schedule',
            occurrences: 1,
            startDateTime: campaign.ends_at.iso8601,
            period: '3 years' # doesn't matter given the occurrence value of 1.
          }
        },
        {
          id: 'Ec2Resource',
          name: 'Ec2Resource',
          fields: {
            type: 'Ec2Resource',
            imageId: AwsOps::Infrastructure.latest_ami(AwsOps::ASG_WORKER_NAME),
            instanceType: AwsOps::PRODUCTION_SIZE,
            keyPair: AwsOps::KEYPAIR_NAME,
            runAsUser: AwsOps::USERNAME,
            securityGroupIds: wsOps::Infrastructure.security_groups_per_worker[AwsOps::ASG_WORKER_NAME]
          }
        }
      ]
    })
  end
  
  def self.id_for c
    "campaign_fulfillment_check_#{c}"
  end
  
end