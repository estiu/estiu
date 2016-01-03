describe 'Pledge refund, by credit creation', js: true do
  
  sign_as :attendee, :feature
  
  let(:campaign){ FG.create :campaign, :unfulfilled, including_attendees: [attendee.attendee] }
  
  let(:pledge){ attendee.attendee.pledge_for(campaign) }
  
  it "works" do
    
    visit campaign_path(campaign)
    
    find('.unfulfilled-refund-option-credits').click
    
    expect {
      find('.refund-action').click
    }.to change {
      Credit.count
    }.by(1)
    
  end
  
end