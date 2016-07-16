describe CampaignDraftsController do
  
  def the_action
    get :index
  end
  
  describe '#index' do
    
    context "as an event promoter" do
      
      sign_as :event_promoter
      
      after do
        controller_ok
      end

      def the_test
        expect(CampaignDraft).to receive(:all).at_least(1).times.and_call_original
        the_action
      end
      
      context "with campaign drafts" do
        
        before {
          FG.create :campaign_draft, event_promoter: event_promoter.event_promoter
        }
        
        it 'works' do
          the_test
        end
        
      end
      
      context "without campaign drafts" do
        
        before {
          expect(CampaignDraft.count).to be_zero
        }
        
        it 'works' do
          the_test
        end
        
      end
      
    end
    
    # admins without an event promoter role are forbidden from viewing drafts. Kinda makes sense.
    context 'forbidden roles' do
      
      before {
        expect_unauthorized
        the_action
      }
      
      context "with campaign drafts" do
        
        before {
          FG.create :campaign_draft
        }
        
        forbidden_for(nil, :attendee, :admin)
      
      end
      
      context "without campaign drafts" do
        
        before {
          expect(CampaignDraft.count).to be_zero
        }
        
        forbidden_for(nil, :attendee, :admin)
      
      end
      
    end
    
  end
  
end