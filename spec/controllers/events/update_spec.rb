describe EventsController do
  
  describe 'update' do
    
    describe 'as an event promoter' do
      
      sign_as :event_promoter
      
      let(:old_value){ event.name }
      let(:new_value){ SecureRandom.hex }
      
      let(:params){ {id: event.id, event: {name: new_value}} }
      
      def the_action
        put :update, params
      end
      
      context "given an unsubmitted event I created" do
        
        let(:event){ FG.create :event, event_promoter_id: event_promoter.event_promoter_id}
        
        it "is possible to update the event" do
          
          expect {
            the_action
          }.to change {
            event.reload.name
          }
          
        end
        
      end
      
      context "given a submitted event I created" do
        
        let(:event){ FG.create :event, :submitted, event_promoter_id: event_promoter.event_promoter_id}
        
        it "is not possible to update the event" do
          
          expect {
            the_action
          }.to_not change {
            event.reload.name
          }
          
        end
        
      end
      
      context "given an unsubmitted event I created" do
        
        let(:event){ FG.create :event }
        
        it "is not possible to update the event" do
          
          expect {
            the_action
          }.to_not change {
            event.reload.name
          }
          
        end
        
      end
      
    end
    
    context 'forbidden roles' do
      
      let(:event){ FG.create :event }
      
      before {
        expect_unauthorized
        put :update, {id: event.id, event: {name: SecureRandom.hex}}
      }
      
      forbidden_for(nil, :attendee)
      
    end
    
  end
  
end