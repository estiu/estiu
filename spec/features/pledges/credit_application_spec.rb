describe 'Credit application', js: true do
  
  context 'as an attendee' do
    
    sign_as :attendee, :feature
    
    let(:referrers_count){ 3 }
    let!(:past_campaign){ FG.create :campaign, :with_referred_attendee, referred_attendee: attendee.attendee, referrers_count: referrers_count }
    let(:campaign){ FG.create :campaign }
    let(:different_campaign) { FG.create :campaign }
  
    before {
      visit campaign_path(campaign)
    }
    
    let(:charge){
      double(id: SecureRandom.hex)
    }
    
    before {
      expect(Stripe::Charge).to receive(:create).once.with(any_args).and_return(charge)
    }
    
    def the_action
      find('#do-pledge').click
      # accept_dialog # XXX instead: expect "you will pay / you will be discounted" rows to be updated
      fill_stripe_form
      sleep 7
    end
    
    it 'is possible to apply discounts' do
      
      [attendee.attendee.credits.first.id, attendee.attendee.credits.last.id].each do |id|
        find("#pledge_desired_credit_ids_#{id}").click
      end
      expect {
        the_action
      }.to change {
        campaign.pledges.count
      }.by(1)
      
    end
    
    it 'causes credit consumption' do
      
      [attendee.attendee.credits.first.id, attendee.attendee.credits.last.id].each do |id|
        find("#pledge_desired_credit_ids_#{id}").click
      end
      
      expect {
        the_action
      }.to change {
        attendee.attendee.credits.count
      }.by(-2)
      
    end
    
    
    it 'causes 2 out of 3 discounts to not appear anymore' do
      
      expect(all('input.desired_credit_ids').size).to be 3
      
      [attendee.attendee.credits.first.id, attendee.attendee.credits.last.id].each do |id|
        find("#pledge_desired_credit_ids_#{id}").click
      end
      
      the_action
      
      visit campaign_path(different_campaign)
      
      expect(all('input.desired_credit_ids').size).to be 1
      
    end
    
  end
  
end