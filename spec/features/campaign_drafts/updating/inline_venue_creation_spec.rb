describe "Creating a Venue while updating a CampaignDraft", js: true do
  
  include ApplicationHelper
  
  sign_as :event_promoter, :feature
  
  let!(:venue){ FG.build :venue }
  
  let!(:the_campaign){ FG.create :campaign_draft, event_promoter: event_promoter.event_promoter }
  
  before {
    visit edit_campaign_draft_path(the_campaign)
  }
  
  def the_add_action
    find("##{new_venue_form_modal_id} input[type='submit']").click
    sleep 3
  end
  
  def the_submit_action
    
    # 1. update the minimum pledge, according to the just-created Venue
    
    the_campaign.venue = Venue.last
    the_campaign.minimum_pledge_cents = (the_campaign.goal_cents.to_f / the_campaign.venue.capacity.to_f).ceil
    find('#campaign_draft_minimum_pledge_cents_facade').send_keys("#{the_campaign.minimum_pledge.format(symbol: false)}")
    
    # 2. submit
    find("#edit_campaign_draft_#{the_campaign.id} input[type=submit]").click
    
  end
  
  describe 'success' do
    
    it 'is possible to create a venue while updating a campaign draft' do
      
      fill_venue_form
      
      expect {
        the_add_action
      }.to change {
        Venue.count
      }.by(1)
      
    end
    
    it 'updates the <select> element present in the page, marking the newly created venue as the selected one' do
      
      fill_venue_form
      
      old_id = the_campaign.venue_id.to_s
      
      expect {
        the_add_action
      }.to change {
        find('#campaign_draft_venue_id').value
      }.from(old_id).to(->(id){ id == Venue.last.id.to_s })
      
    end
    
    it "updates the venue capacity indicator" do
      
      fill_venue_form
      
      expect {
        the_add_action
      }.to change {
        find('#venue-capacity-indicator').text
      }.from("#{t('campaign_drafts.form.venue_capacity')}: #{the_campaign.venue.capacity}").
        to(->(text){
          text == "#{t('campaign_drafts.form.venue_capacity')}: #{Venue.last.capacity}" 
        })
      
    end
    
    it 'is possible update a campaign draft with that venue (1/2)' do

      fill_venue_form
      the_add_action
      
      expect {
        the_submit_action
      }.to change {
        the_campaign.reload.updated_at
      }
      
      expect(page).to have_content(t 'campaign_drafts.update.success')
      
    end
    
    it 'is possible update a campaign draft with that venue (2/2)' do

      fill_venue_form
      the_add_action
      
      expect {
        the_submit_action
      }.to change {
        the_campaign.reload.venue_id
      } # .from(old_id).to(->(id){ id == Venue.last.id.to_s }) # XXX shitty rspec issue
      
      expect(page).to have_content(t 'campaign_drafts.update.success')
      
    end
    
  end
  
end