class CampaignUnfulfillmentCheckJob < ApplicationJob
  
  def perform campaign_id, force_run=false
    return if !Rails.env.production? && !force_run
    AwsOps::Pipeline.schedule_campaign_unfulfillment_check(Campaign.find(campaign_id))
  end
  
end