describe CampaignsController do
  
  def the_test
    get :mine
  end
  
  describe 'permitted roles' do
    
    after do
      controller_ok
    end
    
    context 'event_promoter role' do
      
      sign_as :event_promoter
      
      context "with Campaigns" do
        
        before {
          FG.create :campaign, campaign_draft: FG.build(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id)
        }
        
        it 'works' do
          the_test
        end
        
      end
      
      context "without Campaigns" do
        
        before {
          expect(Campaign.count).to be_zero
        }
        
        it 'works' do
          the_test
        end
        
      end
      
    end
    
    context 'attendee role' do
      
      sign_as :attendee
      
      context "with Campaigns" do
        
        before {
          FG.create :campaign
        }
        
        it 'works' do
          the_test
        end
        
      end
      
      context "without Campaigns" do
        
        before {
          expect(Campaign.count).to be_zero
        }
        
        it 'works' do
          the_test
        end
        
      end
      
    end
    
    context 'any other role' do
      
      sign_as :admin
      
      context "with Campaigns" do
        
        before {
          FG.create :campaign
        }
        
        it 'works' do
          the_test
        end
        
      end
      
      context "without Campaigns" do
        
        before {
          expect(Campaign.count).to be_zero
        }
        
        it 'works' do
          the_test
        end
        
      end
      
    end
    
  end
  
  context 'forbidden roles' do
    
    before {
      expect_unauthorized
      the_test
    }
    
    forbidden_for(nil)
    
  end
    
end