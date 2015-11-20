class CampaignFulfillment::EventPromoterMailer < ApplicationMailer
  
  def perform campaign
    @campaign = campaign
    @cta_url = new_event_campaign_url(id: @campaign.id)
    mail(to: campaign.event_promoter.email, subject: t(".subject"))
  end
  
end