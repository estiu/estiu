describe "Rejecting a submitted event", js: true do
  
  sign_as :admin, :feature
  
  let(:event){ FG.create :event, :submitted }
  
  it "works" do
    
    visit event_path(event)
    
    find('.review-option-reject').click
    
    expect {
      find('.review-action').click
    }.to change {
      event.reload.rejected_at.nil?
    }.from(true).to(false)
    
    expect(page).to have_content(t('events.show.rejected'))
    
  end
  
end