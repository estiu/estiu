class Events::Approval::EventPromoterNotificationPreview < ActionMailer::Preview
  
  def perform
    event = Event.where.not(approved_at: nil).first || FG.create(:event, :submitted, :approved)
    Events::Approval::EventPromoterNotificationMailer.perform(event)
  end
  
end