class CampaignUnfulfillment::AttendeePreview < ActionMailer::Preview
  
  def perform
    CampaignUnfulfillment::AttendeeMailer.perform(Pledge.first)
  end
  
end