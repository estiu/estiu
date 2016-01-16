class Events::Approval::TicketNotificationPreview < ActionMailer::Preview
  
  def perform
    ticket = Ticket.last || FG.create(:ticket)
    Events::Approval::TicketNotificationMailer.perform(ticket)
  end
  
end