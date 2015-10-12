describe CampaignsController do
  
  context 'event_promoter role' do
    
    for_role :event_promoter

    after do
      controller_ok
    end
    
    describe '#new' do
      
      it 'works' do
        
        expect(Campaign).to receive(:new).once.and_call_original
        get :new
        
      end
      
    end
  
  end
    
end