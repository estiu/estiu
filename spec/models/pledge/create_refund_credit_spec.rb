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
    
  end
  
end