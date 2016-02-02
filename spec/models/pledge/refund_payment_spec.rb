describe Pledge do
  
  describe '#refund_payment!' do
    
    let(:attendee){ FG.create :attendee }
    
    let(:campaign){ FG.create :campaign, :unfulfilled, including_attendees: [attendee] }
    
    let(:pledge){ attendee.pledge_for(campaign) }
    
    let(:charge){
      double(id: SecureRandom.hex)
    }
    
    context "success" do
      
      before {
        expect(Stripe::Refund).to receive(:create).once.with({charge: pledge.stripe_charge_id}).and_return(charge)
      }
      
      before {
        expect(PaymentRefundConfirmationMailer).to receive(:perform).at_least(1).times.and_call_original
      }
      
      it "works" do
        
        expect(pledge.refund_payment!).to be true
        
      end
      
    end
    
    context "non refundable pledges" do
      
      context "when a pledge hasn't been charged" do
        
        let(:pledge){ FG.create :pledge, attendee: attendee, stripe_charge_id: nil }
        
        before { expect(pledge.campaign.active?).to be true }
        
        it "is not refundable" do
          expect(pledge.refund_payment!).to be false
        end
        
      end
      
    end
    
    context "already refunded" do
      
      def already_refunded
        2.times { expect(pledge.refund_payment!).to be false }
      end
      
      context "via refund payment" do
        
        before {
          expect(Stripe::Refund).to receive(:create).once.with({charge: pledge.stripe_charge_id}).and_return(charge)
          expect(pledge.refund_payment!).to be true
        }
        
        it "doesn't work" do
          already_refunded
        end
        
      end
      
      context "via refund credit" do
        
        before {
          expect(pledge.create_refund_credit!).to be true
        }
        
        it "doesn't work" do
          already_refunded
        end
        
      end
      
    end
    
  end
  
end