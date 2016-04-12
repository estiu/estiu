describe EventsController do
  
  describe '#show' do
    
    context "event_promoter" do
      
      sign_as :event_promoter
      
      before {
        get :show, id: event.id
      }
      
      context "the promoter is related to the campaign" do
        
        let(:event){
          campaign = FG.create :campaign, :fulfilled, campaign_draft: FG.build(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id)
          FG.create :event, campaign: campaign
        }
        
        it 'is permitted' do
          controller_ok
        end
        
      end
      
      context "unrelated promoter" do
        
        let(:event){ FG.create :event }
        
        it 'is forbidden' do
          forbidden_expectation
        end
        
      end
      
    end
    
    context "attendee" do
      
      sign_as :attendee
      
      before {
        get :show, id: event.id
      }
      
      context "when the attendee pledged for the campaign" do
        
        let(:campaign){ FG.create :campaign, :fulfilled, including_attendees: [attendee.attendee] }
        
        let(:event){ FG.create :event, :submitted, :approved, campaign: campaign }
        
        it "is permitted" do
          controller_ok
        end
        
      end
      
      context "when the attendee didn't pledge for the campaign" do
        
        let(:event) { FG.create :event }
        
        it "is forbidden" do
          forbidden_expectation
        end
        
      end
      
    end
    
    context "forbidden roles" do
      
      let(:event) { FG.create :event }
      
      before {
        expect_unauthorized
        get :show, id: event.id
      }
      
      forbidden_for(nil, :artist_promoter)
      
    end
    
  end
  
end