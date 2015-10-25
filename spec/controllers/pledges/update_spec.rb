describe PledgesController, retry: 0 do
  
  describe '#update' do
    
    let(:campaign){
      FG.create :campaign
    }
    
    let(:amount_cents){
      campaign.minimum_pledge_cents
    }
    
    let(:most_campaign_params){
      {
        id: campaign.id,
        pledge_id: pledge.id,
        pledge: {amount_cents: amount_cents},
        stripeToken: SecureRandom.hex
      }
    }
    
    def the_action
      put :update, campaign_params
    end
    
    def the_count
      campaign.pledges.count # this because only charged pledges are in the default_scope. charging a pledge doesn't change the real count, but it does charge the AR one.
    end
    
    def campaign_params
      most_campaign_params.merge(pledge_id: pledge.id)
    end
    
    context 'active campaign' do
      
      context "attendee which hasn't been charged to his pledge for this campaign" do
        
        sign_as :attendee
        
        let(:pledge) {
          Pledge.create!(campaign: campaign, attendee: attendee.attendee, amount_cents: amount_cents, originally_pledged_cents: amount_cents)
        }
        
        let(:charge){
          double(id: SecureRandom.hex)
        }
        
        before {
          args = {
            amount: amount_cents,
            currency: Pledge::STRIPE_EUR,
            source: campaign_params[:stripeToken],
            description: Pledge.charge_description_for(campaign)
          }
          expect(Stripe::Charge).to receive(:create).once.with(args).and_return(charge)
          expect(charge).to receive(:id).exactly(2).times
        }
        
        it 'allows to create a pledge' do
          expect{
            the_action
          }.to change {
            the_count
          }.by(1)
        end
        
      end
      
      context "attendee which already has been charged for a pledge to this campaign" do
        
        sign_as(->(*_){ 
          FG.create(:user, :attendee_role, attendee: FG.create(:attendee, pledges: [FG.build(:pledge, campaign: campaign, amount_cents: amount_cents, stripe_charge_id: SecureRandom.hex)]))
        }, false, :user)
        
        let(:pledge){
          user.attendee.pledges.first
        }
        
        before {
          expect(user.attendee.pledged?(campaign)).to be true
        }
        
        before {
          expect_unauthorized
        }
        
        it "doesn't allow to create a pledge" do
          expect{
            the_action
          }.to_not change {
            the_count
          }
        end
        
      end
      
    end
    
    context 'inactive campaign' do
      
      before {
        allow_any_instance_of(Campaign).to receive(:active?).and_return false
      }
      
      context "attendee which has an uncharged pledge for this campaign" do
        
        sign_as(->(*_){ 
          FG.create(:user, :attendee_role, attendee:
            FG.create(:attendee, pledges: [FG.build(:pledge, campaign: campaign, amount_cents: amount_cents)]))
        }, false, :user)
        
        let(:pledge){
          Pledge.unscoped.where(attendee: user.attendee).first
        }
        
        before {
          expect(pledge.id).to be_present
        }
        
        before {
          expect_unauthorized
        }
        
        it "doesn't allow to create a pledge" do
          expect{
            the_action
          }.to_not change {
            campaign.pledges.count
          }
        end
        
      end
      
    end
    
  end
  
end