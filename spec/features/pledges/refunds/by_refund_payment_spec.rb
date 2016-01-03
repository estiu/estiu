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
  
  it "works" do
    
    visit campaign_path(campaign)
    
    find('.unfulfilled-refund-option-money_back').click
    
    expect {
      find('.refund-action').click
    }.to change {
      pledge.reload.stripe_refund_id
    }.from(nil).to(charge.id)
    
  end
  
end