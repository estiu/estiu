describe "Rejecting a submitted campaign_draft", js: true do
  
  sign_as :admin, :feature
  
  let(:campaign_draft){ FG.create :campaign_draft, :submitted }
  
  it "works" do
    
    visit campaign_draft_path(campaign_draft)
    
    find('.review-option-reject').click
    
    expect {
      find('.review-action').click
    }.to change {
      campaign_draft.reload.rejected_at.present?
    }.from(false).to(true)
    
    expect(page).to have_content(t('campaign_drafts.reject.success'))
    
  end
  
end