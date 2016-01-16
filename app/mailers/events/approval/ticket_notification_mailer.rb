class Events::Approval::TicketNotificationMailer < ApplicationMailer
  
  def perform ticket
    @event = event = ticket.event
    @campaign = event.campaign
    @name = event.name
    @date = event.starts_at
    mail(to: ticket.attendee.user.email, subject: t("mailers.events.approval.ticket_notification_mailer.perform.subject", id: event.id, name: @name))
  end
  
end