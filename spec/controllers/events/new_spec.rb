describe EventsController do
  
  describe '#new' do
    
    context "event_promoter" do
      
      sign_as :event_promoter
      
      before {
        get :new, id: campaign.id
      }
      
      context "event_promoter of a campaign with pending event" do
        
        let(:campaign){
          FG.create :campaign, :fulfilled, campaign_draft: FG.build(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id)
        }
        
        it 'is permitted' do
          controller_ok
        end
        
        it 'renders nested_attributes' do
          expect(response).to render_template(partial: 'fields/_nested_attributes')
        end
        
      end
      
      context "event_promoter of a campaign having an event already" do
        
        let(:campaign){
          FG.create :campaign, :fulfilled, :with_event, campaign_draft: FG.build(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id)
        }
        
        it "is forbidden" do
          forbidden_expectation
        end
        
      end
      
      context "event_promoter of an unrelated campaign" do
        
        let(:campaign){ FG.create :campaign, :fulfilled }
        
        it "is forbidden" do
          forbidden_expectation
        end
        
      end
      
    end
    
    context "forbidden roles" do
      
      let(:campaign){ FG.create :campaign, :fulfilled }
      
      before {
        expect_unauthorized
        get :new, id: campaign.id
      }
      
      forbidden_for(nil, :artist_promoter, :artist, :attendee)
      
    end
    
  end
  
end