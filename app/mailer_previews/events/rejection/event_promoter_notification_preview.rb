class Events::Rejection::EventPromoterNotificationPreview < ActionMailer::Preview
  
  def perform
    event = Event.where.not(rejected_at: nil).first || FG.create(:event, :submitted, :rejected)
    Events::Rejection::EventPromoterNotificationMailer.perform(event)
  end
  
end