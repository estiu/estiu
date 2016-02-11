describe "Campaign draft deletion" do
  
  sign_as :event_promoter, :feature
  
  let!(:campaign){ FG.create :campaign_draft, :step_1, event_promoter: event_promoter.event_promoter }
  
  before {
    visit campaign_draft_path(campaign)
  }
  
  def the_action
    find("#delete-draft-#{campaign.id}").click
  end
  
  it "is possible to delete a campaign draft" do
    
    expect {
      the_action
    }.to change {
      CampaignDraft.count
    }.by(-1)
    
  end
  
end