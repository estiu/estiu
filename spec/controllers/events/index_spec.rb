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
            Event.all.each(&:destroy) unless with_events
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
            
            it 'works' do
              get :index
            end
            
          end
          
          context 'attendee role' do
            
            sign_as :attendee
            
            it 'works' do
              get :index
            end
            
          end
          
        end
        
      end
      
    end
    
  end

end