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
    
    expect(page).to have_content(t('events.show.approved_will_take_place_admin'))
    
  end
  
end