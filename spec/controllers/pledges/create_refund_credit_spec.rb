describe PledgesController do
  
  describe '#create_refund_credit' do
    
    sign_as :attendee
    
    let(:campaign){ FG.create :campaign, :unfulfilled, including_attendees: [attendee.attendee] }
    
    let(:pledge){ attendee.attendee.pledge_for(campaign) }
    
    def the_action
      get :create_refund_credit, id: pledge.campaign.id, pledge_id: pledge.id
    end
    
    it 'works' do
      expect {
        the_action
      }.to change {
        Credit.count
      }.by(1)
    end
    
    it "only works the first time" do
      
      expect {
        the_action
        the_action
        the_action
      }.to change {
        Credit.count
      }.by(1)
      
    end
    
    context "when the attendee has already used the other available refund choice" do
      
      let(:charge){
        double(id: SecureRandom.hex)
      }
      
      before {
        expect(Stripe::Refund).to receive(:create).once.with({charge: pledge.stripe_charge_id}).and_return(charge)
        expect(pledge.refund_payment!).to be true
      }
      
      it "doesn't work" do
        
        expect {
          the_action
        }.to_not change {
          Credit.count
        }
        
      end
      
    end
    
  end
  
end