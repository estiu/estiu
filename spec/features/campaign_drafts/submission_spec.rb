describe 'Campaign submission', js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:campaign){ FG.create :campaign_draft, event_promoter: event_promoter.event_promoter }
  
  before {
    visit campaign_draft_path(campaign)
  }
  
  it "is possible to submit a campaign" do
    
    expect {
      find("#edit_campaign_draft_#{campaign.id} input[type=submit]").click
    }.to change {
      campaign.reload.submitted_at.present?
    }.from(false).to(true)
    
    expect(page).to have_content(t('campaign_drafts.submit.success'))
    
  end
  
end