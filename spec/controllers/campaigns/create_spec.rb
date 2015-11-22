describe CampaignsController do
  
  context 'event_promoter role' do
    
    sign_as :event_promoter
    
    let(:campaign){ FG.build(:campaign) }
    
    let!(:campaign_params){
      v = {campaign: {}}
      Campaign::CREATE_ATTRS.each do |attr|
        v[:campaign][attr] = campaign.send attr
      end
      Campaign::DATE_ATTRS.each do |attr|
        v[:campaign][attr] = campaign.send(attr).advance(days: 1).strftime(Date::DATE_FORMATS[:default])
      end
      v[:campaign].merge!({
        "starts_at(4i)" => "23",
        "starts_at(5i)" => "59",
        "ends_at(4i)" => "23",
        "ends_at(5i)" => "59"
      })
      v
    }
    
    describe '#create' do
      
      describe 'success' do
        
        after do
          controller_ok(302)
          expect(response).to redirect_to(campaign_path(id: Campaign.last.id))
        end
          
        it 'creates a Campaign' do
          
          expect(Campaign).to receive(:new).exactly(2).times.and_call_original
          expect_any_instance_of(Campaign).to receive(:save).once.and_call_original
          expect{
            post :create, campaign_params
          }.to change{
            Campaign.count
          }.by(1)
        end
        
      end
      
      describe 'generic invalid input' do
        
        after { controller_ok }
        
        let(:incomplete_params){
          v = campaign_params
          v[:campaign][:name] = nil
          v
        }
        
        it "doesn't create a campaign" do
          expect{
            post :create, incomplete_params
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
          
          let(:starts_at){ DateTime.new(2016, 1, 1, 1, 1) }
          let(:ends_at){ starts_at.advance(days: 1) }
          
          let(:distinct_value){ "22" }
          
          let(:time_params){{
            "starts_at(4i)" => distinct_value,
            "starts_at(5i)" => distinct_value,
          }}
          
          let(:causality_checking){ false }
          
          let(:params){
            v = campaign_params
            v[:campaign][:starts_at] = starts_at.strftime(Date::DATE_FORMATS[:default])
            v[:campaign][:ends_at] = ends_at.strftime(Date::DATE_FORMATS[:default])
            v[:campaign].merge!(time_params) unless causality_checking
            v
          }
          
          def the_test negative=false
            expect{
              post :create, params
            }.to change{
              Campaign.count
            }
            expect(Campaign.last.starts_at.strftime('%H')).send((negative ? :to_not : :to), eq(distinct_value))
            expect(Campaign.last.starts_at.strftime('%M')).send((negative ? :to_not : :to), eq(distinct_value))
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
        
      end
      
    end
    
  end
  
  context 'forbidden roles' do
    
    before {
      expect_unauthorized
      post :create
    }
    
    forbidden_for(nil, :attendee)
    
  end
  
end