describe 'Creating a campaign draft by preselecting the venue in Venues#index' do
  
  sign_as :event_promoter, :feature
  
  before {
    FG.create :venue
    visit venues_path
  }
  
  it "works" do
    
    the_button = first('.create-campaign-from-venue', visible: false)
    venue_id = the_button['data-venue-id'].presence || fail
    the_button.click
    sleep 3
    expect(find('#campaign_draft_venue_id').value).to eq venue_id
    
  end
  
end