describe CampaignsController do
  
  describe '#show' do
    
    describe 'when the campaign is unfulfilled' do
      
      let(:campaign){ FG.create(:campaign, :unfulfilled) }
      
      before do
        expect(Campaign).to receive(:find).with(campaign.id.to_s).once.and_call_original
      end

      def the_action
        get :show, id: campaign.id
      end
      
      def basic
        the_action
        expect(response).to render_template(partial: 'campaigns/_unfulfilled')
        expect(response).to_not render_template(partial: 'campaigns/unfulfilled/_money_back')
        expect(response).to_not render_template(partial: 'campaigns/unfulfilled/_credits')
      end
      
      def complete
        the_action
        expect(response).to render_template(partial: 'campaigns/_unfulfilled')
        expect(response).to render_template(partial: 'campaigns/unfulfilled/_money_back')
        expect(response).to render_template(partial: 'campaigns/unfulfilled/_credits')
      end
      
      it "renders correctly" do
        basic
      end
      
      context "as an attendee" do
        
        sign_as :attendee
        
        it "renders correctly" do
          basic
        end
        
        context "when the attendee pledged for the campaign" do
          
          before {
            FG.create :pledge, campaign: campaign, attendee: attendee.attendee
            expect(attendee.attendee.refundable_pledge_for(campaign)).to be_present
          }
          
          it "renders correctly" do
            complete
          end
          
        end
        
      end
      
    end
    
  end
  
end