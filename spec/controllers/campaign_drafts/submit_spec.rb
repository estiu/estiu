describe CampaignDraftsController do
  
  def the_action
    post :submit, id: campaign.id
  end
  
  context 'event_promoter role' do
    
    sign_as :event_promoter
    
    let!(:campaign){ FG.create(:campaign_draft, event_promoter: event_promoter.event_promoter) }
    
    describe '#submit' do
      
      describe 'success' do
        
        after do
          controller_ok 302
        end
          
        it 'successfully sets the campaign as published' do
          
          expect_any_instance_of(CampaignDraft).to receive(:save).once.and_call_original
          expect{
            the_action
          }.to change{
            campaign.reload.submitted_at
          }
        end
        
      end
      
    end
    
  end
  
  context 'forbidden roles' do
    
    let!(:campaign){ FG.create(:campaign_draft) }
    
    before {
      expect_unauthorized
      the_action
    }
    
    forbidden_for(nil, :attendee)
    
  end
  
end