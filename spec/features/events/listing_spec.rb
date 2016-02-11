describe 'Events listing' do
  
  describe 'as an event promoter' do
  
    sign_as :event_promoter, :feature
    
    describe "Displaying campaigns with pending events" do
      
      def the_test negative=false
        visit events_path
        campaigns = Campaign.joins(:campaign_draft).without_event.where(campaign_drafts: {event_promoter_id: event_promoter.event_promoter_id})
        expect(campaigns.size.zero?).to be !!negative
        campaigns.each do |campaign|
          expect(all("a[href='#{campaign_path(campaign)}']").size).to be 1
        end
        expect(all('.alert.alert-warning').size).send((negative ? :to_not : :to), eq(1))
      end
      
      context "when there are pending campaigns" do
        
        before {
          FG.create :campaign, :fulfilled, campaign_draft: FG.create(:campaign_draft, event_promoter_id: event_promoter.event_promoter_id)
        }
        
        it "is displayed a warning with the corresponding links" do
          the_test
        end
        
      end
      
      context "when there aren't pending campaigns" do
        
        it "there is no warning" do
          the_test :negative
        end
        
      end
      
    end
    
  end
  
end