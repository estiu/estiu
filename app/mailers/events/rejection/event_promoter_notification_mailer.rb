class Events::Rejection::EventPromoterNotificationMailer < ApplicationMailer
  
  def perform event
    mail(to: event.event_promoter.email, subject: t(".subject"))
  end
  
end