describe 'Draft listing', js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:drafts){
    [
      FG.create(:campaign_draft, event_promoter: event_promoter.event_promoter),
      FG.create(:campaign_draft, :submitted, event_promoter: event_promoter.event_promoter),
      FG.create(:campaign_draft, :approved, event_promoter: event_promoter.event_promoter),
      FG.create(:campaign_draft, :published, event_promoter: event_promoter.event_promoter)
    ]
  }
  
  before {
    visit campaign_drafts_path
  }
  
  it "works" do
    
    expect(all('#all-campaign-drafts li').size).to be (drafts.size - 1)
    
  end
  
end