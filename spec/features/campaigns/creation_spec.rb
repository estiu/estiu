describe "Campaign creation", js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:campaign){ FG.create :campaign }
  
  before{
    FG.create :venue
  }
  
  before {
    visit new_campaign_path
  }
  
  def fill_starts_at
    find('#campaign_starts_at').click
    next_month
    any_day
  end
  
  def fill_ends_at
    find("#campaign_ends_at").click
    next_month
    next_month
    any_day
  end
  
  def fill_most
    find('#campaign_name').set(campaign.name)
    find('#campaign_goal_cents_facade').set(campaign.goal_cents / 100)
    find('#campaign_minimum_pledge_cents_facade').send_keys("#{campaign.minimum_pledge.format(symbol: false)}")
    find('#campaign_starts_immediately').find("option[value='false']").select_option
    find('#campaign_venue_id').find("option[value='#{campaign.venue.id}']").select_option
    fill_starts_at
    fill_ends_at
    find('#campaign_visibility').find("option[value='public']").select_option
    find('#campaign_generate_invite_link').find("option[value='false']").select_option
  end
  
  def the_last_field
    'description'
  end
  
  def fill_last
    find("#campaign_#{the_last_field}").set(campaign.description)
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
      
      expect(find(".help-block.#{the_last_field}-error.error-is-blank")).to have_content(t 'errors.messages.blank')
      
    end
    
  end
  
  describe 'date/time fields handling' do
    
    describe 'any date field' do
      
      def the_starts_at_value
        page.evaluate_script "$('#campaign_starts_at').val()"
      end
      
      it 'persists across failed submissions' do
        
          fill_most # but don't fill_last
          starts_at_value = the_starts_at_value
          the_action
          expect(the_starts_at_value).to eq(starts_at_value)
        
      end
      
      context 'when no value is passed at submission' do
        
        it 'keeps being empty on the next page' do
          
          fill_most # but don't fill_last
          the_action
          expect(page.evaluate_script("$('##{the_last_field}').val()")).to be_blank
          
        end
        
      end
      
    end
    
    describe 'any time field' do
      
      def minute_selector
        find('#campaign_starts_at_5i option:last-child')
      end
      
      it 'persists across failed submissions' do
        
        find('#campaign_starts_immediately').find("option[value='false']").select_option
        minute_selector.select_option
        value = minute_selector.value
        the_action
        expect(minute_selector.value).to eq value
        
      end
      
    end
    
  end
  
end