describe CampaignsController do

  let(:campaign){ FG.build(:campaign) }
  let!(:campaign_params){
    v = {campaign: {}}
    Campaign::CREATE_ATTRS.each do |attr|
      v[:campaign][attr] = campaign.send attr
    end
    v
  }
  
  describe '#create' do
    
    describe 'success' do
      
      after do
        controller_ok(302)
        expect(response).to redirect_to(campaign_path(id: Campaign.last.id))
      end
        
      it 'creates a Campaign' do
        
        expect(Campaign).to receive(:new).once.and_call_original
        expect_any_instance_of(Campaign).to receive(:save).once.and_call_original
        expect{
          post :create, campaign_params
        }.to change{
          Campaign.count
        }.by(1)
      end
      
    end
    
    describe 'invalid input' do
      
      after { controller_ok }
      
      let(:incomplete_params){
        v = campaign_params
        v[:campaign][:name] = nil
        v
      }
      
      it "doesn't create a campaign" do
        expect{
          post :create, incomplete_params
        }.to_not change{
          Campaign.count
        }
  
      end
      
    end
    
  end
  
end