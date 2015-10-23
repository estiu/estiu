class CampaignFulfillmentJob < ActiveJob::Base
  
  # rendering N mails takes time, which justifies creating a job-creating job.
  def perform campaign_id
    campaign = Campaign.find campaign_id
    campaign.pledges.each do |pledge|
      CampaignFulfillment::AttendeeMailer.perform(pledge.id).deliver_later
    end
    CampaignFulfillment::EventPromoterMailer.perform(campaign).deliver_later
  end
  
end