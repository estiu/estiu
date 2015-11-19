describe EventsController do
  
  describe '#index' do
    
    context 'forbidden roles' do
      
      before {
        expect_unauthorized
        get :index
      }
      
      forbidden_for(nil, :artist_promoter, :artist)
      
    end
    
    context 'permitted roles' do
      
      after do
        controller_ok
      end
      
      [true, false].each do |with_events|
        
        context "with #{"no" unless with_events}events" do
          
          before {
            Event.all.each(&:destroy!) unless with_events
            expect(Event.count).send((with_events ? :to_not : :to), be(0))
          }
          
          context 'admin role' do
            
            sign_as :admin
            
            it 'works' do
              get :index
            end
            
          end
          
          context 'event_promoter role' do
            
            sign_as :event_promoter
            
            before {
              if with_events
                event = FG.create :event, event_promoter_id: event_promoter.event_promoter.id
                expect(Pundit.policy_scope(event_promoter, Event)).to include event
              end
            }
            
            it 'works' do
              get :index
            end
            
          end
          
          context 'attendee role' do
            
            sign_as :attendee
            
            before {
              if with_events
                event = FG.create :event, campaign: FG.create(:campaign, :fulfilled, including_attendees: [attendee.attendee])
                expect(Pundit.policy_scope(attendee, Event)).to include event
              end
            }
            
            it 'works' do
              get :index
            end
            
          end
          
        end
        
      end
      
    end
    
  end

end