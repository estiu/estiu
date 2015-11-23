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
      
      it 'works' do
        
        expect(Campaign).to receive(:all).at_least(1).times.and_call_original
        the_action
        
      end
      
    end

  end
  
  context 'forbidden roles' do
    
    before {
      expect_unauthorized
      the_action
    }
    
    forbidden_for(nil)
    
  end
  
end