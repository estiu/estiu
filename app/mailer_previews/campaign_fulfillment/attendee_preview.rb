class CampaignFulfillment::AttendeePreview < ActionMailer::Preview
  
  def perform
    CampaignFulfillment::AttendeeMailer.perform(Pledge.where.not(campaign_id: nil, attendee_id: nil).first)
  end
  
end