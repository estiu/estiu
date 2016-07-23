describe VenuesController do
  
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
      
      [true, false].each do |with_venues|
        
        context "with #{"no" unless with_venues}venues" do
          
          before {
            if with_venues
              FG.create :campaign_draft, :published # this results in both a Venue and an active Campaign being created.
            else
              Venue.all.each(&:destroy!)
            end
            expect(Venue.count).send((with_venues ? :to_not : :to), be(0))
            expect(Venue.with_active_campaigns.count).send((with_venues ? :to_not : :to), be(0))
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