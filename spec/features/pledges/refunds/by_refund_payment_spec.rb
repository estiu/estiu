describe 'Pledge refund, by payment', js: true do
  
  sign_as :attendee, :feature
  
  let(:campaign){ FG.create :campaign, :unfulfilled, including_attendees: [attendee.attendee] }
  
  let(:pledge){ attendee.attendee.pledge_for(campaign) }
  
  let(:charge){
    double(id: SecureRandom.hex)
  }
  
  before {
    expect(Stripe::Refund).to receive(:create).once.with({charge: pledge.stripe_charge_id}).and_return(charge)
  }
  
  def the_test
    
    visit campaign_path(campaign)
    
    find('.unfulfilled-refund-option-money_back').click
    
    expect {
      find('.refund-action').click
    }.to change {
      pledge.reload.stripe_refund_id
    }.from(nil).to(charge.id)
    
  end
  
  context "when the pledge is refundable because the campaign was unfulfilled" do
    
    let(:campaign){ FG.create :campaign, :unfulfilled, including_attendees: [attendee.attendee] }
    
    before {
      expect(campaign.event).to be nil
    }
    
    it "works" do
      the_test
    end
    
  end
  
  context "when the pledge is refundable because the event was rejected", truncate: true do
    
    let(:campaign){ FG.create(:campaign, :fulfilled, :with_submitted_event, including_attendees: [attendee.attendee]) }
    let(:event) { campaign.event }
    
    before {
      expect(campaign.fulfilled_at).to be_present
      expect(campaign.unfulfilled_at).to be_blank
      expect(campaign.attendees).to include(attendee.attendee)
    }
    
    before {
      event.reload
      expect(event.must_be_reviewed?).to be true
      event.reject!
    }
    
    it "works" do
      the_test
    end
    
  end
  
end