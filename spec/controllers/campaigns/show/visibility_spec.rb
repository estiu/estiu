describe CampaignsController do
  
  let(:campaign){ FG.create(:campaign) }
  
  before do
    expect(Campaign).to receive(:find).with(campaign.id.to_s).once.and_call_original
  end

  def the_action
    get :show, params.merge(id: campaign.id)
  end
  
  def forbidden
    the_action
    expect(subject).to rescue_from(Pundit::NotAuthorizedError).with :user_not_authorized
    forbidden_expectation
  end
  
  let(:params){ {} }
  
  describe '#show - campaign visibility' do
    
    context "public visibility" do
      
      before { expect(campaign.visibility).to eq(CampaignDraft::PUBLIC_VISIBILITY) }
      
      it 'works' do
        the_action
        controller_ok
      end
      
    end
    
    context "app visibility" do
      
      let(:campaign){ FG.create :campaign, campaign_draft: FG.build(:campaign_draft, :published, visibility: CampaignDraft::APP_VISIBILITY) }
      
      context "signed out" do
      
        it "is forbidden" do
          forbidden
        end
        
        
      end
      
      context "as an attendee" do
        
        sign_as :attendee
        
        context "without passing the invite link" do
          it 'is permitted' do
            the_action
            controller_ok
          end
        end

      end
      
    end
    
    context "invite only" do
      
      let(:campaign){ FG.create :campaign, campaign_draft: FG.build(:campaign_draft, :published, visibility: CampaignDraft::INVITE_VISIBILITY, generate_invite_link: true) }
      
      context "signed out" do
        
        context "without passing the invite link" do
          it "is forbidden" do
            forbidden
          end
        end
        
        context "passing the invite link" do
          let(:params){ {invite_token: campaign.invite_token} }
          it 'is permitted' do
            the_action
            controller_ok
          end
        end
        
      end
      
      context "as an attendee" do
        
        sign_as :attendee
        
        context "without passing the invite link" do
          
          it "is forbidden" do
            forbidden
          end
          
          context "having pledged to this campaign" do
            
            before {
              FG.create :pledge, attendee: attendee.attendee, campaign: campaign
            }
            
            it "is permitted" do
              the_action
              controller_ok
            end
            
          end
          
        end
        
        context "passing the invite link" do
          let(:params){ {invite_token: campaign.invite_token} }
          it 'is permitted' do
            the_action
            controller_ok
          end
        end
        
      end
      
      context "event promoter" do
        
        sign_as :event_promoter
        
        context "as the event promoter who created the event" do
          
          let(:campaign) {
            FG.create :campaign, campaign_draft: FG.build(:campaign_draft, :published, visibility: CampaignDraft::INVITE_VISIBILITY, generate_invite_link: true, event_promoter: event_promoter.event_promoter)
          }
          
          context "without passing the invite link" do
            it 'is permitted' do
              the_action
              controller_ok
            end
          end
          
        end
        
        context "viewing an unlreated, invite-only campaign" do
          
          context "without passing the invite link" do
            it 'is forbidden' do
              forbidden
            end
          end
          
          context "passing the invite link" do
            let(:params){ {invite_token: campaign.invite_token} }
            it 'is permitted' do
              the_action
              controller_ok
            end
          end
          
        end
        
      end
      
    end
    
  end

end