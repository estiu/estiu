describe PledgesController do
  
  describe '#update' do
    
    let(:campaign){
      FG.create :campaign
    }
    
    let(:new_originally_pledged_cents){
      rand(campaign.minimum_pledge_cents..Pledge::MAXIMUM_PLEDGE_AMOUNT)
    }
    
    let(:campaign_params){
      {
        id: campaign.id,
        pledge_id: the_pledge.id,
        pledge: {originally_pledged_cents: new_originally_pledged_cents},
      }
    }
    
    def the_action
      put :update, campaign_params
    end
    
    def the_count attendee
      Pledge.unscoped.where(stripe_charge_id: nil, campaign: campaign, attendee: attendee).count
    end
    
    def the_pledge
      Pledge.unscoped.find_by(campaign: campaign, attendee_id: user.attendee_id)
    end
    
    context 'active campaign' do
      
      context "when there exists a Pledge object, which hasn't been charged" do
        
        sign_as :attendee, false, :user
        
        before {
          FG.create(:pledge, attendee: user.attendee, campaign: campaign, stripe_charge_id: nil)
        }
        
        before {
          expect(user.attendee.pledged?(campaign)).to be false
        }
        
        it 'allows to update that pledge' do
          expect{
            the_action
          }.to change {
            the_pledge.originally_pledged_cents
          }.and change {
            the_pledge.amount_cents
          }
        end
        
      end
      
      context 'attendee which has been charged already for a pledge to this campaign' do
        
        sign_as :attendee, false, :user
        
        before {
          FG.create(:pledge, attendee: user.attendee, campaign: campaign, stripe_charge_id: SecureRandom.hex)
        }
        
        before {
          expect(user.attendee.pledged?(campaign)).to be true
        }
        
        before {
          expect_unauthorized
        }
        
        it "is forbidden to update a pledge" do
          expect{
            the_action
          }.to_not change {
            the_pledge.originally_pledged_cents
          }
        end
        
        it "is forbidden to update a pledge" do
          expect{
            the_action
          }.to_not change {
            the_pledge.amount_cents
          }
        end
        
      end
    
    end
    
  end
  
end