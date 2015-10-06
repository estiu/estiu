describe "Campaign creation", js: true do
  
  let(:campaign){ FG.build :campaign }
  
  before {
    visit new_campaign_path
  }
  
  def fill_most
    find('#campaign_name').set(campaign.name)
    find('#campaign_description').set(campaign.description)
    find('#campaign_goal_cents_facade').set(campaign.goal_cents / 100)
    find('#campaign_starts_at').click
    find('table.ui-datepicker-calendar tbody tr:first-child td:last-child').click
  end
  
  def fill_last
    find('#campaign_ends_at').click
    find('table.ui-datepicker-calendar tbody tr:last-child td:last-child').click
  end
  
  def the_action
    find('#new_campaign input[type=submit]').click
  end
  
  describe 'success' do
    
    it 'is possible to create a campaign' do

      fill_most
      fill_last
      
      expect {
        the_action
      }.to change {
        Campaign.count
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
        Campaign.count
      }
      
      expect(page).to have_content("Ends at can't be blank")
      
    end
    
  end
  
end