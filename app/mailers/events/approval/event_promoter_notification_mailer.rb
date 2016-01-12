class Events::Approval::EventPromoterNotificationMailer < ApplicationMailer
  
  def perform event
    @event = event
    mail(to: event.event_promoter.email, subject: t("mailers.events.approval.event_promoter_notification_mailer.perform.subject", id: event.id, name: event.name))
  end
  
end