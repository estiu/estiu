describe "Creating a Venue while updating an Event", js: true do
  
  include ApplicationHelper
  
  sign_as :event_promoter, :feature
  
  let(:the_event){ FG.create :event, event_promoter_id: event_promoter.event_promoter_id }
  let(:venue){ FG.build :venue }
  let(:initial_path) { event_path(the_event) }
  
  before {
    visit initial_path
    find('.edit-this-event').click
  }
  
  def fill_event_form
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
    find("#edit_event_#{the_event.id} input[type=submit]").click rescue binding.pry
  end
  
  describe 'success' do
    
    it 'is possible to create a venue while updating an event' do
      
      fill_venue_form
      
      expect {
        the_add_action
      }.to change {
        Venue.count
      }.by(1)
      
    end
    
    it 'updates the <select> element present in the page, marking the newly created venue as the selected one' do
      
      fill_venue_form
      old_id = the_event.venue_id.to_s
      
      expect {
        the_add_action
      }.to change {
        find('#event_venue_id').value
      }.from(old_id).to(->(id){ id == Venue.last.id.to_s })
      
    end
    
    it 'is possible to update the event with that venue (1/2)' do
      
      fill_venue_form
      the_add_action
      fill_event_form
      
      old_id = the_event.venue_id
      
      expect {
        the_submit_action
      }.to change {
        the_event.reload.updated_at
      }
      
      expect(page).to have_content(t 'events.update.success')
      
    end
    
    it 'is possible to update the event with that venue (2/2)' do
      
      fill_venue_form
      the_add_action
      fill_event_form
      
      old_id = the_event.venue_id
      
      expect {
        the_submit_action
      }.to change {
        the_event.reload.venue_id
      } # .from(old_id).to(->(id){ id == Venue.last.id.to_s }) # XXX shitty rspec issue
      
      expect(page).to have_content(t 'events.update.success')
      
    end
    
  end
  
end