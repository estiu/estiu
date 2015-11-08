class CampaignUnfulfillmentCheckJob < ActiveJob::Base
  
  def perform campaign_id
    return unless Rails.env.production?
    AwsOps::Pipeline.schedule_campaign_unfulfillment_check(Campaign.find(campaign_id))
  end
  
end