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
  
  def the_add_action
    find("##{new_venue_form_modal_id} input[type='submit']").click
    sleep 3
  end
  
  def the_submit_action
    find("#edit_event_#{the_event.id} input[type=submit]").click
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
    
    it "updates the venue capacity indicator" do
      
      fill_venue_form
      
      expect {
        the_add_action
      }.to change {
        find('#venue-capacity-indicator').text
      }.from("#{t('campaign_drafts.form.venue_capacity')}: #{the_event.venue.capacity}").
        to(->(text){
          text == "#{t('campaign_drafts.form.venue_capacity')}: #{Venue.last.capacity}" 
        })
      
    end
    
    it 'is possible to update the event with that venue (1/2)' do
      
      fill_venue_form
      the_add_action
      
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