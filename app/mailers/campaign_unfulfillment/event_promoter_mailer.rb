class CampaignUnfulfillment::EventPromoterMailer < ApplicationMailer
  
  def perform campaign
    @campaign = campaign
    @campaign_url = campaign_url(@campaign)
    @raised_amount = campaign.pledged.format
    @goal_amount = campaign.goal.format
    @new_campaign_url = new_campaign_draft_url
    mail(to: campaign.event_promoter.email, subject: t(".subject"))
  end
  
end