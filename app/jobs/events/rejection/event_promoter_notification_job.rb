class Events::Rejection::EventPromoterNotificationJob < ApplicationJob
  
  def perform event_id
    event = Event.find event_id
    Events::Rejection::EventPromoterNotificationMailer.perform(event).deliver_now
  end
  
end