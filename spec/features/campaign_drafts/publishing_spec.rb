describe "Campaign draft publishing", js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:campaign){ FG.create :campaign_draft, :approved, event_promoter: event_promoter.event_promoter }
  
  before{
    FG.create :venue
  }
  
  before {
    visit campaign_draft_path(campaign)
  }
  
  def fill_starts_at
    find('#campaign_draft_starts_at').click
    next_month
    any_day
  end
  
  def fill_ends_at
    find("#campaign_draft_ends_at").click
    next_month
    next_month
    any_day
  end
  
  def fill_most
    find('#campaign_draft_starts_immediately').find("option[value='false']").select_option
    find('#campaign_draft_time_zone').find("option[value='#{Estiu::Timezones::FOR_SELECT.sample[1]}']").select_option
    fill_starts_at
    fill_ends_at
    find('#campaign_draft_visibility').find("option[value='public']").select_option
  end
  
  def the_last_field
    'generate_invite_link'
  end
  
  def fill_last
    find('#campaign_draft_generate_invite_link').find("option[value='false']").select_option
  end
  
  def the_action
    find("#edit_campaign_draft_#{campaign.id} input[type=submit]").click
  end
  
  describe 'success' do
    
    it 'is possible to submit a campaign' do

      fill_most
      fill_last
      
      expect {
        the_action
      }.to change {
        campaign.reload.published_at
      }
      
      expect(page).to have_content(t 'campaign_drafts.publish.success')
      
    end
    
    context "when I choose to start the campaign right now, rather than at a specific date/time" do
      
      before {
        fill_most
        find('#campaign_draft_starts_immediately').find("option[value='true']").select_option
        fill_last
      }
      
      def the_test
        expect {
          the_action
        }.to change {
          campaign.reload.published_at
        }
        expect(CampaignDraft.last.starts_immediately).to be true
        expect(CampaignDraft.last.starts_at).to be nil
      end
      
      it 'is possible to successfully create that campaign' do
        the_test
      end
      
    end
    
  end
  
  describe 'incomplete input' do
    
    it 'results in the form being rendered again' do
      
      fill_most
      
      expect {
        the_action
      }.to_not change {
        campaign.reload.published_at
      }
      
      expect(find(".help-block.#{the_last_field}-error")).to have_content(t 'errors.inclusion')
      
    end
    
  end
  
  describe 'date/time fields handling' do
    
    describe 'any date field' do
      
      def the_starts_at_value
        page.evaluate_script "$('#campaign_draft_starts_at').val()"
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
        find('#campaign_draft_starts_at_5i')
      end
      
      it 'persists across failed submissions' do
        
        find('#campaign_draft_starts_immediately').find("option[value='false']").select_option
        find('#campaign_draft_time_zone').find("option[value='#{Estiu::Timezones::FOR_SELECT.sample[1]}']").select_option
        minute_selector.find('option:last-child').select_option
        value = minute_selector.value
        the_action
        expect(minute_selector.value).to eq value
        
      end
      
    end
    
    describe 'the time zone selector' do
      
      context "when I don't select it" do
        
        before { expect(find('#campaign_draft_time_zone').value).to be_blank }
        
        context "and I submit" do
          
          before { the_action }
          
          it "the page doesn't throw any error" do
            
            page_ok 200, :feature
            
          end
          
        end
        
      end
      
    end
    
  end
  
end