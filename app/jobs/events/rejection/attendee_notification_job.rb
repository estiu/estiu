class Events::Rejection::AttendeeNotificationJob < ApplicationJob
  
  def perform event_id
    event = Event.find event_id
    event.campaign.pledges.each do |pledge|
      Events::Rejection::AttendeeNotificationMailer.perform(pledge).deliver_later
    end
  end
  
end