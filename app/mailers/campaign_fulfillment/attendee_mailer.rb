class CampaignFulfillment::AttendeeMailer < ApplicationMailer
  
  def perform pledge_id
    pledge = Pledge.find pledge_id
    @campaign = pledge.campaign
    mail(to: pledge.attendee.user.email, subject: t(".subject"))
  end
  
end