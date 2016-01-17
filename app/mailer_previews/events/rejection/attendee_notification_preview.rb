class Events::Rejection::AttendeeNotificationPreview < ActionMailer::Preview
  
  def perform
    pledge = Pledge.last || FG.create(:pledge)
    Events::Rejection::AttendeeNotificationMailer.perform(pledge)
  end
  
end