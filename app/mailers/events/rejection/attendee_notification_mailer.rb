class Events::Rejection::AttendeeNotificationMailer < ApplicationMailer
  
  def perform pledge
    mail(to: pledge.attendee.user.email, subject: t(".subject"))
  end
  
end