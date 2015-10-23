class CampaignFulfillment::EventPromoterPreview < ActionMailer::Preview
  
  def perform
    CampaignFulfillment::EventPromoterMailer.perform(Campaign.where.not(fulfilled_at: nil).first)
  end
  
end