describe "Creating a Venue while creating an Event", js: true do
  
  include ApplicationHelper
  
  sign_as :event_promoter, :feature
  
  let!(:campaign) { FG.create :campaign, :fulfilled, campaign_draft: FG.build(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id) }
  let!(:the_event){ FG.build :event }
  let!(:venue){ FG.build :venue }
  
  before { visit new_event_campaign_path(id: campaign.id) }
  
  def fill_event_form event=the_event
    find('#event_name').set SecureRandom.hex
    find('#event_starts_at_date').click
    next_month
    any_day
    options = find('#event_starts_at_hours').all("option")
    options[(1..(options.size - 1)).to_a.sample].select_option
    options = find('#event_duration_hours').all("option")
    options[(1..(options.size - 1)).to_a.sample].select_option
    find('#event_ra_artists_attributes_0_artist_path').set "dj/#{SecureRandom.hex}"
  end
  
  def the_add_action
    find("##{new_venue_form_modal_id} input[type='submit']").click
    sleep 3
  end
  
  def the_submit_action
    find('#new_event input[type=submit]').click
  end
  
  describe 'success' do
    
    it 'is possible to create a venue while creating an event' do
      
      fill_venue_form
      
      expect {
        the_add_action
      }.to change {
        Venue.count
      }.by(1)
      
    end
    
    it 'updates the <select> element present in the page, marking the newly created venue as the selected one' do
      
      fill_venue_form
      
      expect {
        the_add_action
      }.to change {
        find('#event_venue_id').value
      }.from("").to(->(id){ id == Venue.last.id.to_s })
      
    end
    
    it 'is possible to create an event with that venue' do
      
      fill_venue_form
      the_add_action
      the_id = Venue.last.id
      fill_event_form(FG.build(:event))
      
      expect {
        the_submit_action
      }.to change {
        Event.count
      }.by(1)
      
      expect(page).to have_content(t 'events.create.success')
      expect(Event.last.venue_id).to eq(the_id)
      
    end
    
  end
  
end