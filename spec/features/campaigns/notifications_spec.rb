describe 'Header notifications' do
  
  context "attendee" do
    
    sign_as :attendee, :feature
    
    context "fulfilled campaigns for which this attendee did pledge" do
      
      def the_count
        all('.header-notification').size
      end
      
      context "when there are" do
        
        before {
          campaign = FG.create :campaign, :fulfilled, including_attendees: [attendee.attendee]
          expect(campaign.event).to be nil
        }
        
        it "is displayed" do
          
          visit '/'
          expect(the_count).to be 1
          
        end
        
      end
      
      context "when there aren't" do
        
        it "is not necessary to display anything" do
          
          visit '/'
          expect(the_count).to be 0
          
        end
        
      end
      
    end
    
  end
  
end