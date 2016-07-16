describe CampaignDraftsController do
  
  context 'event_promoter role' do
    
    sign_as :event_promoter

    after do
      controller_ok
    end
    
    describe '#new' do
      
      it 'works' do
        
        expect(CampaignDraft).to receive(:new).once.and_call_original
        get :new
        
      end
      
    end
  
  end
  
  context 'forbidden roles' do
    
    before {
      expect_unauthorized
      get :new
    }
    
    forbidden_for(nil, :attendee, :admin)
    
  end
  
end