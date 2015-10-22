describe PledgesController do
  
  describe '#create' do
    
    let(:campaign){
      FG.create :campaign
    }
    
    let(:amount_cents){
      campaign.minimum_pledge_cents
    }
    
    let(:campaign_params){
      {
        id: campaign.id,
        pledge: {amount_cents: amount_cents},
      }
    }
    
    def the_action
      post :create, campaign_params
    end
    
    def the_count attendee
      Pledge.unscoped.where(stripe_charge_id: nil, campaign: campaign, attendee: attendee).count
    end
    
    context 'active campaign' do
      
      context "attendee which hasn't pledged to this campaign" do
        
        sign_as :attendee, false, :user
        
        before {
          expect(the_count(user.attendee)).to be 0
        }
        
        it 'allows to create a pledge' do
          expect{
            the_action
          }.to change {
            the_count(user.attendee)
          }.by(1)
        end
        
      end
      
      context "attendee which has created non-charged pledges for this campaign" do
        
        sign_as(->(*_){ 
          FG.create(:user, :attendee_role, attendee:
            FG.create(:attendee, pledges: [FG.build(:pledge, campaign: campaign, amount_cents: amount_cents)]))
        }, false, :user)
        
        before {
          expect(the_count(user.attendee)).to be 1
          expect(user.attendee.pledged?(campaign)).to be false
        }
        
        it "is allowed to create a pledge" do
          expect{
            the_action
          }.to change {
            the_count(user.attendee)
          }.by(1)
        end
        
      end
      
      context 'attendee which has been charged already for a pledge to this campaign' do
        
        sign_as(->(*_){ 
          FG.create(:user, :attendee_role, attendee: FG.create(:attendee, pledges: [FG.build(:pledge, campaign: campaign, amount_cents: amount_cents, stripe_charge_id: SecureRandom.hex)]))
        }, false, :user)
        
        before {
          expect(user.attendee.pledged?(campaign)).to be true
        }
        
        before {
          expect_unauthorized
        }
        
        it "is forbidden to create a pledge" do
          expect{
            the_action
          }.to_not change {
            the_count(user.attendee)
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
      
      before {
        allow_any_instance_of(Campaign).to receive(:active?).and_return false
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