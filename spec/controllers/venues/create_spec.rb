describe VenuesController do
  
  %w(event campaign_draft).each do |type|
    
    let(:the_type){ type }
    
    describe "#create (for #{type})" do
      
      def venue_params
        v = FG.build :venue
        entries = Venue::CREATE_ATTRS.map{|attr| [attr, v.send(attr)] }
        {
          venue: Hash[entries].merge({VenuesController::OBJECT_FOR_FORM_KEY => the_type}),
          format: :js
        }
      end
      
      def incomplete_venue_params
        p = venue_params
        p[:venue].except!(Venue::CREATE_ATTRS.first)
        p
      end
      
      %i(event_promoter admin).each do |role|
        
        describe "as an #{role}" do
          
          sign_as role
          
          describe 'success' do
            
            after do
              controller_ok
            end
              
            it "is possible to create a Venue" do
              
              expect {
                post :create, venue_params
              }.to change {
                Venue.count
              }.by(1)
              
            end
            
          end
          
          describe 'validation errors' do
            
            it "is handled when I don't provide enough info to create a Venue" do
              
              expect {
                post :create, incomplete_venue_params
              }.to_not change {
                Venue.count
              }
              
              expect(response.status).to eq 422
              
            end
            
          end
          
        end
        
      end
      
      context 'forbidden roles' do
        
        context "With complete venue params" do
          
          before {
            expect_unauthorized
            post :create, venue_params
          }
          
          forbidden_for(nil, :attendee)
          
        end
        
        context "With incomplete venue params" do
          
          before {
            expect_unauthorized
            post :create, incomplete_venue_params
          }
          
          forbidden_for(nil, :attendee)
          
        end
        
      end
      
    end
    
  end
  
end