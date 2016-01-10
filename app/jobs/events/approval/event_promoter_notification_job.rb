class Events::Approval::EventPromoterNotificationJob < ApplicationJob
  
  def perform event_id
    event = Event.find event_id
    Events::Approval::EventPromoterNotificationMailer.perform(event).deliver_now
  end
  
end