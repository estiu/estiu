class CampaignUnfulfillment::AttendeeMailer < ApplicationMailer
  
  def perform pledge_id
    pledge = Pledge.find pledge_id
    @campaign = pledge.campaign
    @campaign_url = campaign_url(@campaign)
    @another_campaign_url = campaigns_url
    @amount = pledge.amount.format
    mail(to: pledge.attendee.user.email, subject: t(".subject", first_name: pledge.attendee.first_name))
  end
  
end