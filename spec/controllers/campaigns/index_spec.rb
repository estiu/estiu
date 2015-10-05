describe CampaignsController do
  
  after do
    controller_ok
  end

  describe '#index' do
    
    it 'works' do
      
      expect(Campaign).to receive(:all).once.and_call_original
      get :index
      
    end
    
  end
  
end