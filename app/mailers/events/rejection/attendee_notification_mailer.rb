class Events::Rejection::AttendeeNotificationMailer < ApplicationMailer
  
  def perform pledge
    @campaign = pledge.campaign
    @event_promoter = @campaign.event_promoter
    mail(to: pledge.attendee.user.email, subject: t("mailers.events.rejection.attendee_notification_mailer.perform.subject", id: @campaign.id, campaign: @campaign))
  end
  
end