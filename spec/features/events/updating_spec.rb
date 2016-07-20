describe "Updating an unsubmitted event", js: true do
  
  sign_as :event_promoter, :feature
  
  let(:event){ FG.create :event, event_promoter_id: event_promoter.event_promoter_id }
  let(:initial_path) { event_path(event) }
  
  before {
    visit initial_path
    find('.edit-this-event').click
  }
  
  let(:old_value){ event.name }
  let(:new_value){ SecureRandom.hex }
  
  def submit
    find("#edit_event_#{event.id} input[type=submit]").click
  end
  
  it "is possible to update an event before it's submitted" do
    
    find('#event_name').set new_value
    
    expect {
      submit
    }.to change {
      event.reload.name
    }.from(old_value).to(new_value)
    
  end
  
  describe 'the venue capacity indicator' do
    
    it "displays its correspondingly value correctly at load time" do
      
      expect(find('#venue-capacity-indicator').text).to eq("#{t('campaign_drafts.form.venue_capacity')}: #{event.venue.capacity}")
      
    end
    
  end
  
  describe 'deleting a ra_artist'  do
    
    it "is possible to delete single ra_artist" do
      
      all('.remove-nested-attribute-item').last.click
      
      expect {
        submit
      }.to change {
        event.reload.ra_artists.count
      }.by(-1)
      
    end
    
  end
  
end