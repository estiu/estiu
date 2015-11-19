describe CampaignsController do

  describe 'permitted roles' do
    
    after do
      controller_ok
    end
    
    context 'event_promoter role' do
      
      sign_as :event_promoter
      
      it 'works' do
        get :mine
      end
      
    end
    
    context 'attendee role' do
      
      sign_as :attendee
      
      it 'works' do
        get :mine
      end
      
    end
    
    context 'any other role' do
      
      sign_as :admin
      
      it 'works too' do
        get :mine
      end
      
    end
    
  end
  
  context 'forbidden roles' do
    
    before {
      expect_unauthorized
      get :mine
    }
    
    forbidden_for(nil)
    
  end
    
end