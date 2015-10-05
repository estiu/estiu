describe CampaignsController do
  
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