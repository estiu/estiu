describe CampaignsController do
  
  let(:promoter) { FG.create(:user, :event_promoter) }
  
  before do
    promoter.confirm
    sign_in :user, promoter
  end
  
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