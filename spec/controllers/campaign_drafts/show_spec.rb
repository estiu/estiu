describe CampaignDraftsController do
  
  describe '#show' do
    
    sign_as :event_promoter
    
    let(:campaign){ FG.create(:campaign_draft, :published, event_promoter: event_promoter.event_promoter) }
    
    it "loads correctly" do
      
      get :show, id: campaign.id
      
      controller_ok
      
    end
    
  end

end