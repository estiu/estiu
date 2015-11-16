class CampaignUnfulfillmentUnscheduleJob < ApplicationJob
  
  def perform campaign_id
    return unless Rails.env.production?
    AwsOps::Pipeline.unschedule_campaign_unfulfillment_check campaign_id
  end
  
end