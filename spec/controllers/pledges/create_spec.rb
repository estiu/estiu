describe PledgesController do
  
  describe '#create' do
    
    let(:campaign){
      FG.create :campaign
    }
    
    let(:amount_cents){
      campaign.recommended_pledge_amount_cents
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
        
        sign_as :attendee
        
        before {
          expect(the_count(attendee.attendee)).to be 0
        }
        
        it 'allows to create a pledge' do
          expect{
            the_action
          }.to change {
            the_count(attendee.attendee)
          }.by(1)
        end
        
      end
      
      context "attendee which has created non-charged pledges for this campaign" do
        
        sign_as ->(*_){ 
          FG.create(:user, :attendee_role, attendee:
            FG.create(:attendee, pledges: [FG.build(:pledge, campaign: campaign, amount_cents: amount_cents)]))
        }
        
        before {
          attendee = User.last.attendee
          expect(the_count(attendee)).to be 1
          expect(attendee.pledged?(campaign)).to be false
        }
        
        it "is allowed to create a pledge" do
          attendee = User.last.attendee
          expect{
            the_action
          }.to change {
            the_count(attendee)
          }.by(1)
        end
        
      end
      
      context 'attendee which has been charged already for a pledge to this campaign' do
        
        sign_as ->(*_){ 
          FG.create(:user, :attendee_role, attendee: FG.create(:attendee, pledges: [FG.build(:pledge, campaign: campaign, amount_cents: amount_cents, stripe_charge_id: SecureRandom.hex)]))
        }
        
        before {
          expect(User.last.attendee.pledged?(campaign)).to be true
        }
        
        before {
          expect_unauthorized
        }
        
        it "is forbidden to create a pledge" do
          attendee = User.last.attendee
          expect{
            the_action
          }.to_not change {
            the_count(attendee)
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
      
      before {
        expect(campaign).to_not be_active
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