describe PledgesController do
  
  describe '#refund_payment' do
    
    sign_as :attendee
    
    let(:campaign){ FG.create :campaign, :unfulfilled, including_attendees: [attendee.attendee] }
    
    let(:pledge){ attendee.attendee.pledge_for(campaign) }
    
    let(:charge){
      double(id: SecureRandom.hex)
    }
    
    def the_action
      get :refund_payment, id: pledge.campaign.id, pledge_id: pledge.id
    end
    
    def the_expectation negative=false
      if negative
        expect {
          the_action
        }.to_not change {
          pledge.reload.stripe_refund_id
        }
      else
        expect(Stripe::Refund).to receive(:create).once.with({charge: pledge.stripe_charge_id}).and_return(charge)
        expect {
          the_action
        }.to change {
          pledge.reload.stripe_refund_id
        }.from(nil).to(charge.id)
      end
    end
    
    it 'works' do
      the_expectation
    end
    
    it "only works the first time" do
      the_expectation
      the_expectation :negative
      the_expectation :negative
    end
    
    context "when the attendee has already used the other available refund choice" do
      
      before {
        expect(pledge.create_refund_credit!).to be true
      }
      
      it "doesn't work" do
        the_expectation :negative
      end
      
    end
      
  end
  
end