describe Pledge do
  
  describe '#refund_payment!' do
    
    let(:attendee){ FG.create :attendee }
    
    let(:campaign){ FG.create :campaign, :unfulfilled, including_attendees: [attendee] }
    
    let(:pledge){ attendee.pledge_for(campaign) }
    
    let(:charge){
      double(id: SecureRandom.hex)
    }
    
    context "success" do
      
      before { expect(Stripe::Refund).to receive(:create).once.with({charge: pledge.stripe_charge_id}).and_return(charge) }
      
      before {
        expect(PaymentRefundConfirmationMailer).to receive(:perform).at_least(1).times.and_call_original
      }
      
      it "works" do
        
        expect(pledge.refund_payment!).to be true
        
      end
      
    end
    
  end
  
end