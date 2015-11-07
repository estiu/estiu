class CampaignUnfulfillmentUnscheduleJob < ActiveJob::Base
  
  def perform campaign_id
    AwsOps::Pipeline.unschedule_campaign_unfulfillment_check campaign_id
  end
  
end