class Events::Approval::TicketCreationJob < ApplicationJob
  
  def perform event_id
    event = Event.find event_id
    event.campaign.attendees.each do |attendee|
      Ticket.create!(event: event, attendee: attendee)
    end
  end
  
end