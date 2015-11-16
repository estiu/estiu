class CampaignUnfulfillmentJob < ApplicationJob
  
  def perform campaign_id
    campaign = Campaign.find campaign_id
    campaign.pledges.each do |pledge|
      CampaignUnfulfillment::AttendeeMailer.perform(pledge.id).deliver_later
    end
    CampaignUnfulfillment::EventPromoterMailer.perform(campaign).deliver_later
  end
  
end