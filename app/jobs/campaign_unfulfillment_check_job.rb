class CampaignUnfulfillmentCheckJob < ApplicationJob
  
  def perform campaign_id, force_run=false
    return if dev_or_test? && !force_run
    AwsOps::Pipeline.schedule_campaign_unfulfillment_check(Campaign.find(campaign_id))
  end
  
end