class Events::Approval::TicketNotificationJob < ApplicationJob
  
  def perform ticket_id
    ticket = Ticket.find ticket_id
    Events::Approval::TicketNotificationMailer.perform(ticket).deliver_now
  end
  
end