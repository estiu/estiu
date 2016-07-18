describe "Creating a Venue while creating a CampaignDraft", js: true do
  
  include ApplicationHelper
  
  sign_as :event_promoter, :feature
  
  let!(:the_campaign){ FG.build :campaign_draft }
  let!(:venue){ FG.build :venue }
  
  before {
    visit new_campaign_draft_path
  }
  
  def fill_campaign_form campaign=the_campaign
    find('#campaign_draft_name').set(campaign.name)
    find('#campaign_draft_cost_justification').set(campaign.cost_justification)
    find('#campaign_draft_goal_cents_facade').set(campaign.goal_cents / 100)
    find('#campaign_draft_minimum_pledge_cents_facade').send_keys("#{campaign.minimum_pledge.format(symbol: false)}")
    find("#campaign_draft_description").set(campaign.description)
  end
  
  def the_add_action
    find("##{new_venue_form_modal_id} input[type='submit']").click
    sleep 3
  end
  
  def the_submit_action
    find('#new_campaign_draft input[type=submit]').click
  end
  
  describe 'success' do
    
    it 'is possible to create a venue while creating a campaign draft' do
      
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
        find('#campaign_draft_venue_id').value
      }.from("").to(->(id){ id == Venue.last.id.to_s })
      
    end
    
    it 'is possible to create a campaign draft with that venue' do

      fill_venue_form
      the_add_action
      fill_campaign_form(FG.build(:campaign_draft, venue: Venue.last)) # use the new venue for campaign cents values
      
      expect {
        the_submit_action
      }.to change {
        CampaignDraft.count
      }.by(1)
      
      expect(page).to have_content(t 'campaign_drafts.create.success')
      expect(CampaignDraft.last.venue_id).to eq(Venue.last.id)
      
    end
    
  end
  
end