describe "Campaign draft creation", js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:campaign){ FG.create :campaign_draft }
  
  before{
    FG.create :venue
  }
  
  before {
    visit new_campaign_draft_path
  }
  
  def step1
    find('#campaign_draft_venue_id').find("option[value='#{campaign.venue.id}']").select_option
    find('#campaign_draft_name').set(campaign.name)
    find('#campaign_draft_goal_cents_facade').set(campaign.goal_cents / 100)
    find('#campaign_draft_minimum_pledge_cents_facade').send_keys("#{campaign.minimum_pledge.format(symbol: false)}")
  end
  
  def fill_most
    step1
  end
  
  def the_last_field
    'description'
  end
  
  def fill_last
    find("#campaign_draft_#{the_last_field}").set(campaign.description)
  end
  
  def the_action
    find('#new_campaign_draft input[type=submit]').click
  end
  
  describe 'success' do
    
    it 'is possible to create a campaign' do

      fill_most
      fill_last
      
      expect {
        the_action
      }.to change {
        CampaignDraft.count
      }.by(1)
      
      expect(page).to have_content(t 'campaigns.create.success')
      
    end
    
  end
  
  describe 'incomplete input' do
    
    it 'results in the form being rendered again' do
      
      fill_most # but don't fill_last
      
      expect {
        the_action
      }.to_not change {
        CampaignDraft.count
      }
      expect(first(".help-block.#{the_last_field}-error.error-is-blank")).to have_content(t 'errors.messages.blank')
      
    end
    
  end
  
end