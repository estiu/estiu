describe CampaignsController do
  
  after do
    controller_ok
  end
  
  let(:campaign){ FG.create(:campaign) }
  
  describe '#show' do
    
    it 'works' do
      
      expect(Campaign).to receive(:find).with(campaign.id.to_s).once.and_call_original
      get :show, id: campaign.id
      
    end
    
  end
  
end