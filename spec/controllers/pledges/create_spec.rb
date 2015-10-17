describe PledgesController do
  
  describe '#create' do
    
    let(:campaign){
      FG.create :campaign
    }
    
    let(:campaign_params){
      {
        id: campaign.id,
        pledge: {amount_cents: campaign.recommended_pledge_amount_cents},
        stripeToken: SecureRandom.hex
      }
    }
    
    let(:charge){
      double(id: SecureRandom.hex)
    }
    
    def the_action
      post :create, campaign_params
    end
  
    context 'active campaign' do
      
      context "attendee which hasn't pledged to this campaign" do
        
        sign_as :attendee
        
        before {
          args = {
            amount: campaign.recommended_pledge_amount_cents,
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
            campaign.pledges.count
          }.by(1)
        end
        
      end
      
      context "attendee which has pledged already to this campaign" do
        
        sign_as ->(*_){ 
          FG.create(:user, :attendee_role, attendee: FG.create(:attendee, pledges: [FG.build(:pledge, campaign: campaign)]))
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
      
      context 'forbidden roles' do
        
        before {
          expect_unauthorized
          the_action
        }
        
        forbidden_for(nil, :event_promoter)
        
      end
          
    end
    
    context 'inactive campaign' do
      
      let(:campaign){
        FG.create :campaign, starts_at: 20.days.ago, ends_at: 10.days.ago
      }
      
      context "attendee which hasn't pledged to this campaign" do
        
        sign_as :attendee
        
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