describe PledgesController do # XXX fobidden_for?
  
  describe '#create' do
    
    let(:campaign){
      FG.create :campaign
    }
    
    let(:campaign_params){
      {id: campaign.id, pledge: {amount_cents: campaign.recommended_pledge_amount_cents}}
    }
    
    def the_action
      post :create, campaign_params
    end
  
    context 'active campaign' do
      
      context "attendee which hasn't pledged to this campaign" do
        
        sign_as :attendee
        
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