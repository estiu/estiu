describe DashboardController do
  
  def the_test
    get :index
  end
  
  describe '#index' do
    
    describe 'permitted roles' do
      
      after do
        controller_ok
      end
      
      context 'event_promoter role' do
        
        sign_as :event_promoter
        
        context "with Campaigns and Events" do
          
          before {
            FG.create :campaign, campaign_draft: FG.build(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id)
            c = FG.create :campaign, :fulfilled, campaign_draft: FG.build(:campaign_draft, :published, event_promoter_id: event_promoter.event_promoter_id)
            FG.create :event, campaign: c
          }
          
          it 'works' do
            the_test
          end
          
        end
        
        context "without Campaigns or Events" do
          
          before {
            expect(Campaign.count).to be_zero
            expect(Event.count).to be_zero
          }
          
          it 'works' do
            the_test
          end
          
        end
        
      end
      
      context 'admin role' do
        
        sign_as :admin
        
        context "with Campaigns and Events" do
          
          before {
            FG.create :campaign, campaign_draft: FG.build(:campaign_draft, :published)
            c = FG.create :campaign, :fulfilled, campaign_draft: FG.build(:campaign_draft, :published)
            FG.create :event, campaign: c
          }
          
          it 'works' do
            the_test
          end
          
        end
        
        context "without Campaigns or Events" do
          
          before {
            expect(Campaign.count).to be_zero
            expect(Event.count).to be_zero
          }
          
          it 'works' do
            the_test
          end
          
        end
        
      end
      
    end
    
    
    context 'forbidden roles' do
      
      before {
        expect_unauthorized
        the_test
      }
      
      context "with Campaigns and Events" do
        
        before {
          FG.create :campaign, campaign_draft: FG.build(:campaign_draft, :published)
          c = FG.create :campaign, :fulfilled, campaign_draft: FG.build(:campaign_draft, :published)
          FG.create :event, campaign: c
        }
        
        forbidden_for(nil, :attendee)
        
      end
      
      context "without Campaigns or Events" do
        
        before {
          expect(Campaign.count).to be_zero
          expect(Event.count).to be_zero
        }
        
        forbidden_for(nil, :attendee)
        
      end
      
    end
      
    
  end
  
end