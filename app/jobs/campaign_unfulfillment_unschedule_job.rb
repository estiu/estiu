class CampaignUnfulfillmentUnscheduleJob < ApplicationJob
  
  def perform campaign_id
    return if dev_or_test?
    AwsOps::Pipeline.unschedule_campaign_unfulfillment_check campaign_id
  end
  
end