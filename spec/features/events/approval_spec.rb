describe "Approving a submitted event", js: true do
  
  sign_as :admin, :feature
  
  let(:event){ FG.create :event, :submitted }
  
  it "works" do
    
    visit event_path(event)
    
    find('.review-option-approve').click
    
    expect {
      find('.review-action').click
    }.to change {
      event.reload.approved_at.nil?
    }.from(true).to(false)
    
    expect(page).to have_content(t('events.approve.success', starts_at: event.starts_at))
    
  end
  
end