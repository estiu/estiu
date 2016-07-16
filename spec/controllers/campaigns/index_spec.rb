describe CampaignsController do
  
  def the_action
    get :index
  end
  
  describe 'logged in' do
    
    sign_as :attendee
    
    after do
      controller_ok
    end

    describe '#index' do
      
      def the_test
        expect(Campaign).to receive(:all).at_least(1).times.and_call_original
        the_action
      end
      
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
      the_action
    }
    
    context "with Campaigns" do
      
      before {
        FG.create :campaign
      }
      
      forbidden_for(nil)
    
    end
    
    context "without Campaigns" do
      
      before {
        expect(Campaign.count).to be_zero
      }
      
      forbidden_for(nil)
    
    end
    
  end
  
end