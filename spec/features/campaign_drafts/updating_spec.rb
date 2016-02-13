describe "Campaign draft updating", js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:campaign){ FG.create :campaign_draft, event_promoter: event_promoter.event_promoter }
  
  before {
    visit edit_campaign_draft_path(campaign)
  }
  
  let(:old_name){ campaign.name }
  let(:new_name){ SecureRandom.hex }
  
  def the_field
    find("#campaign_draft_name")
  end
  
  def the_action
    find("#edit_campaign_draft_#{campaign.id} input[type=submit]").click
  end
  
  describe 'name field' do
    
    describe 'success' do
      
      it "is possible to update a campaign draft's name" do

        the_field.set(new_name)
        
        expect {
          the_action
        }.to change {
          campaign.reload.name
        }.from(old_name).to(new_name)
        
        expect(page).to have_content(t 'campaign_drafts.update.success')
        
      end
      
    end
    
    describe 'incomplete input' do
      
      it 'results in the form being rendered again' do
        
        the_field.set(nil)
        expect {
          the_action
        }.to_not change {
          campaign.reload.updated_at
        }
        expect(first(".help-block.name-error.error-is-blank")).to have_content(t 'errors.messages.blank')
        
      end
      
    end
    
  end
  
  # XXX describe other fields, given their JS-ness/complexity
  
end