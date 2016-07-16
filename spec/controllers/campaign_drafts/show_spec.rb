describe CampaignDraftsController do
  
  describe '#show' do
    
    sign_as :event_promoter
    
    let(:campaign){ FG.create(:campaign_draft, :published, event_promoter: event_promoter.event_promoter) }
    
    def the_action
      get :show, id: campaign.id
    end
    
    it "loads correctly" do
      the_action
      controller_ok
    end
    
    context 'forbidden roles' do
      
      let!(:campaign){ FG.create(:campaign_draft) }
      
      before {
        expect_unauthorized
        the_action
      }
      
      forbidden_for(nil, :attendee, :admin)
      
    end
    
  end

end