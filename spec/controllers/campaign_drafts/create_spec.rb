describe CampaignDraftsController do
  
  context 'event_promoter role' do
    
    sign_as :event_promoter
    
    let(:campaign){ FG.build(:campaign_draft) }
    
    let!(:campaign_params){
      v = {campaign_draft: {}}
      CampaignDraft::CREATE_ATTRS_STEP_1.each do |attr|
        v[:campaign_draft][attr] = campaign.send attr
      end
      CampaignDraft::DATE_ATTRS.each do |attr|
        v[:campaign_draft][attr] = campaign.send(attr).advance(days: 1).strftime(Date::DATE_FORMATS[:default])
      end
      v[:campaign_draft].merge!({
        "starts_immediately" => 'false',
        "starts_at(4i)" => "23",
        "starts_at(5i)" => "59",
        "ends_at(4i)" => "23",
        "ends_at(5i)" => "59"
      })
      v
    }
    
    describe '#create' do
      
      describe 'success' do
        
        after do
          controller_ok(302)
          expect(response).to redirect_to(campaign_draft_path(id: CampaignDraft.last.id))
        end
          
        it 'creates a Campaign' do
          
          expect(CampaignDraft).to receive(:new).exactly(2).times.and_call_original
          expect_any_instance_of(CampaignDraft).to receive(:save).once.and_call_original
          expect{
            post :create, campaign_params
          }.to change{
            CampaignDraft.count
          }.by(1)
        end
        
      end
      
      describe 'generic invalid input' do
        
        after { controller_ok }
        
        let(:incomplete_params){
          v = campaign_params
          v[:campaign_draft][:name] = nil
          v
        }
        
        it "doesn't create a campaign" do
          expect{
            post :create, incomplete_params
          }.to_not change{
            CampaignDraft.count
          }
        end
        
      end
      
    end
    
  end
  
  context 'forbidden roles' do
    
    before {
      expect_unauthorized
      post :create
    }
    
    forbidden_for(nil, :attendee)
    
  end
  
end