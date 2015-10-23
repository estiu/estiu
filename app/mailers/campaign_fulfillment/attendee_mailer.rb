class CampaignFulfillment::AttendeeMailer < ApplicationMailer
  
  def perform pledge_id
    pledge = Pledge.find pledge_id
    @campaign = pledge.campaign
    mail(to: pledge.attendee.user.email, subject: I18n.t(".subject"))
  end
  
end