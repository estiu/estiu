describe EventsController do
  
  describe '#reject' do
    
    sign_as :admin
    
    let(:event){ FG.create :event, :submitted }
    
    it "works" do
      
      expect {
        post :reject, id: event.id
      }.to change {
        event.reload.rejected_at.nil?
      }.from(true).to(false)
      
    end
    
  end
  
end