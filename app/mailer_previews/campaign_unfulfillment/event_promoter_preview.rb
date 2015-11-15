class CampaignUnfulfillment::EventPromoterPreview < ActionMailer::Preview
  
  def perform
    CampaignUnfulfillment::EventPromoterMailer.perform(Campaign.first)
  end
  
end