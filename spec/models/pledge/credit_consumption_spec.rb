describe Pledge do
  
  describe '#charge! - credit consumption' do
    
    before { expect(subject.stripe_charge_id).to be nil  }
    
    let(:token) { SecureRandom.hex }

    let(:charge){
      double(id: SecureRandom.hex)
    }
    
    let(:campaign) { FG.create :campaign, :with_one_pledge }
    
    let(:amount_cents){ campaign.minimum_pledge_cents }
    
    let(:args){
      {
        amount: amount_cents,
        currency: Pledge::STRIPE_EUR,
        source: token,
        description: Pledge.charge_description_for(campaign)
      }
    }
    
    let(:first_attendee){ campaign.attendees.first }
    let(:email){ first_attendee.user.email }
    let!(:referrer_pledge){
      allow(Stripe::Charge).to receive(:create).once.with(args).and_return(charge)
      pledge = FG.create :pledge, campaign: campaign, referral_email: email, stripe_charge_id: nil, amount_cents: amount_cents
      pledge.charge! token
      pledge
    }
    let(:credit){ referrer_pledge.referral_credit }
    
    def the_action
      subject.charge!(token)
    end
    
    let(:pledge_params){
      {
        stripe_charge_id: nil, desired_credit_ids: [credit.id], amount_cents: amount_cents, campaign: campaign
      }
    }
    
    context 'valid desired_credits_ids' do
      
      subject { FG.build :pledge, pledge_params.merge(attendee: first_attendee) }
      
      before {
        subject.calculate_total!
        begin
          subject.save!
        rescue => e # debug flaky test
          puts "subject.amount_cents: #{subject.amount_cents}"
          puts "subject.campaign.minimum_pledge_cents: #{subject.campaign.minimum_pledge_cents}"
          puts "subject.campaign == campaign: #{subject.campaign == campaign}"
          raise e
        end
        allow(Stripe::Charge).to receive(:create).once.with(args.merge(amount: amount_cents - Pledge::DISCOUNT_PER_REFERRAL)).and_return(charge)
      }
      
      it 'works' do
        
        expect {
          a = the_action
        }.to change {
          subject.reload.stripe_charge_id
        }.from(nil).to(charge.id)
        
      end
      
    end
    
    context 'unrelated desired_credits_ids' do
      
      subject { FG.build :pledge, pledge_params } # here the same credit_id is passed, but without the corresponding attendee (FG creates one instead)
      
      before {
        subject.calculate_total!
      }
      
      it 'is not possible to create such a pledge' do
        
        expect(subject.save).to be false
        expect(subject.errors[:desired_credit_ids]).to include I18n.t("pledges.errors.desired_credit_ids")
        
      end
      
    end
    
    context 'concurrent requests, both with valid desired_credits_ids' do
    
      
      
    end
    
  end
  
end