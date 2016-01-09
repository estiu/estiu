describe EventsController do
  
  describe '#approve' do
    
    sign_as :admin
    
    let(:event){ FG.create :event, :submitted }
    
    it "works" do
      
      expect {
        post :approve, id: event.id
      }.to change {
        event.reload.approved_at.nil?
      }.from(true).to(false)
      
    end
    
  end
  
end