describe 'Header notifications' do
  
  def the_count
    all('.header-notification').size
  end
  
  context "attendee" do
    
    sign_as :attendee, :feature
    
    def setup starts_at=30.days.from_now
      campaign = FG.create :campaign, :fulfilled, including_attendees: [attendee.attendee]
      FG.create :event, :submitted, :approved, campaign: campaign, starts_at: starts_at
      visit '/'
    end
    
    context "when there are events visible to the user, not celebrated yet" do
      
      before {
        setup
      }
      
      it "results in a notification" do
        expect(the_count).to be 1
      end
      
    end
    
    context "when there are visible events but celebrated already" do
      
      before {
        setup 30.days.ago
      }
      
      it "results in no notification" do
        expect(the_count).to be 0
      end
      
    end
    
  end
  
  context "event_promoter" do
    
    sign_as :event_promoter, :feature
    
    def setup create_event=false
      campaign = FG.create :campaign, :fulfilled, event_promoter_id: event_promoter.event_promoter_id
      FG.create(:event, campaign: campaign) if create_event
      visit '/'
    end
    
    context 'when the promoter has pending events to create' do
      
      before {
        setup
      }
      
      it "results in a notification" do
        expect(the_count).to be 1
      end
      
    end
    
    context "when the event has been created already" do
      
      before {
        setup :create_event
      }

      it "results in no notification" do
        expect(the_count).to be 0
      end
      
    end
    
  end
  
end