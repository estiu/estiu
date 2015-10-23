class CampaignFulfillment::EventPromoterMailer < ApplicationMailer
  
  def perform campaign
    @campaign = campaign
    mail(to: campaign.event_promoter.email, subject: t(".subject"))
  end
  
end