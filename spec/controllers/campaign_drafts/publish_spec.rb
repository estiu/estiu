describe CampaignDraftsController do
  
  context 'event_promoter role' do
    
    sign_as :event_promoter
    
    let!(:campaign){ FG.create(:campaign_draft, :approved, event_promoter: event_promoter.event_promoter) }
    let(:sample_campaign){ FG.create :campaign_draft, :published }
    
    let!(:campaign_params){
      v = {campaign_draft: {}, id: campaign.id}
      CampaignDraft::CREATE_ATTRS_STEP_2.each do |attr|
        v[:campaign_draft][attr] = sample_campaign.send(attr).to_s
      end
      CampaignDraft::DATE_ATTRS.each do |attr|
        v[:campaign_draft][attr] = sample_campaign.send(attr).advance(days: 1).strftime(Date::DATE_FORMATS[:default])
      end
      v[:campaign_draft].merge!({
        "starts_immediately" => 'false',
        "starts_at(4i)" => "23",
        "starts_at(5i)" => "59",
        "ends_at(4i)" => "23",
        "ends_at(5i)" => "59",
        "estimated_event_date" => 10.years.from_now.to_date.to_s
      })
      v
    }
    
    describe '#publish' do
      
      describe 'success' do
        
        after do
          controller_ok 302
        end
        
        def the_action
          post :publish, campaign_params
        end
        
        it 'successfully sets the campaign as published' do
          
          expect_any_instance_of(CampaignDraft).to receive(:save).once.and_call_original
          expect{
            the_action
          }.to change{
            campaign.reload.published_at
          }
          
        end
        
        it "creates a Campaign" do
          
          expect {
            the_action
          }.to change {
            Campaign.where(campaign_draft: campaign).count
          }.by(1)
          
        end
        
      end
      
      describe 'generic invalid input' do
        
        after { controller_ok }
        
        let(:incomplete_params){
          v = campaign_params
          v[:campaign_draft][:time_zone] = nil
          v
        }
        
        def the_action
          post :publish, incomplete_params
        end
        
        it "doesn't set the campaign as published" do
          expect{
            the_action
          }.to_not change{
            campaign.reload.published_at
          }
        end
        
        it "doesn't result in any Campaign being created" do
          expect{
            the_action
          }.to_not change{
            Campaign.count
          }
        end
        
      end
      
      describe 'date/time fields handing' do
        
        let(:time_params){
          {
            "starts_at(4i)" => "18",
            "starts_at(5i)" => "58",
            "ends_at(4i)" => "23",
            "ends_at(5i)" => "59"
          }
        }
        
        describe 'when date and time are passed' do
          
          let(:starts_at){ DateTime.new(2020, 1, 1, 1, 1) }
          let(:ends_at){ starts_at.advance(days: 1) }
          
          let(:distinct_value){ "22" }
          
          let(:time_params){{
            "starts_at(4i)" => distinct_value,
            "starts_at(5i)" => distinct_value,
          }}
          
          let(:causality_checking){ false }
          
          let(:params){
            v = campaign_params
            v[:campaign_draft][:starts_at] = starts_at.strftime(Date::DATE_FORMATS[:default])
            v[:campaign_draft][:ends_at] = ends_at.strftime(Date::DATE_FORMATS[:default])
            v[:campaign_draft].merge!(time_params) unless causality_checking
            v
          }
          
          def the_test negative=false
            expect{
              post :publish, params
            }.to change{
              campaign.reload.published_at
            }
            expect(campaign.reload.starts_at.strftime('%H')).send((negative ? :to_not : :to), eq(distinct_value))
            expect(campaign.reload.starts_at.strftime('%M')).send((negative ? :to_not : :to), eq(distinct_value))
          end
          
          it 'is the time fields which have priority' do
            the_test
          end
          
          context 'causality checking' do
            
            let(:causality_checking){ true }
            
            it 'relates' do
              the_test :negative
            end
            
          end
          
        end
        
        describe 'when time params are passed, but no date params are passed' do
           
           let(:incomplete_params){
             v = campaign_params
             v[:campaign_draft][:starts_at] = nil
             v[:campaign_draft][:ends_at] = nil
             v[:campaign_draft].merge!(time_params)
             v
           }
           
           def the_test(negative=false)
             expect{
               post :publish, incomplete_params
             }.send((negative ? :to_not : :to), change{
               campaign.reload.published_at
             })
           end
           
           
           it "doesn't result in the campaign being published" do
             the_test :negative
           end
           
           context 'causality' do
             
             before { allow(Causality).to receive(:checking?).exactly(2).times.with('ResettableDates#resettable_dates').and_return(true) }
             
             it "exists a relationship between code and test" do
               the_test
             end
             
           end
           
        end
        
      end
      
    end
    
  end
  
  context 'forbidden roles' do
    
    let!(:campaign){ FG.create(:campaign_draft) }
    
    before {
      expect_unauthorized
      post :publish, id: campaign.id
    }
    
    forbidden_for(nil, :attendee, :admin)
    
  end
  
end