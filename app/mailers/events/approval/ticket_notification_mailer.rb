class Events::Approval::TicketNotificationMailer < ApplicationMailer
  
  def perform ticket
    mail(to: ticket.attendee.user.email, subject: t(".subject"))
  end
  
end