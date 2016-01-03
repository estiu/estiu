describe Pledge do
  
  describe '#create_refund_credit!', truncate: true do
    
    let(:attendee){ FG.create :attendee }
    
    let(:campaign){ FG.create :campaign, :unfulfilled, including_attendees: [attendee] }
    
    let(:pledge){ attendee.pledge_for(campaign) }
    
    context "success" do
      
      before {
        expect(CreditCreationMailer).to receive(:perform).at_least(1).times.and_call_original
      }
      
      it "works" do
        
        expect(pledge.create_refund_credit!).to be true
        
      end
      
    end
    
    context "not refundable" do
      
      let(:pledge){ FG.create :pledge, attendee: attendee, campaign: campaign, stripe_charge_id: nil }
      
      it "doesn't work" do
        expect(pledge.create_refund_credit!).to be false
      end
      
    end
    
    context "already refunded" do
      
      def already_refunded
        2.times { expect(pledge.create_refund_credit!).to be false }
      end
      
      context "via refund payment" do
        
        let(:charge){
          double(id: SecureRandom.hex)
        }
        
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