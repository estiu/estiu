describe CalculationsController do
  
  describe '#calculate_goal_cents' do
    
    def the_formatted_total
      JSON.parse(response.body).fetch 'formatted_total'
    end
    
    def the_formatted_total_without_symbol
      JSON.parse(response.body).fetch 'formatted_total_no_symbol'
    end
    
    def the_cents_total
      JSON.parse(response.body).fetch 'cents_total'
    end
    
    def the_explanation
      JSON.parse(response.body).fetch 'explanation'
    end
    
    def all_response_values_present
      [the_formatted_total, the_formatted_total_without_symbol, the_cents_total, the_explanation].each do |value|
        expect(value).to be_present
      end
    end
    
    describe 'permitted roles' do
      
      after do
        controller_ok
      end
      
      def the_tests
        
        get :calculate_goal_cents, proposed_goal_cents: 0
        all_response_values_present
        expect(Monetize.parse(the_formatted_total).to_i).to eq 0
        
        # ---
        
        get :calculate_goal_cents, proposed_goal_cents: 1
        all_response_values_present
        
        # ---
        
        [1_00, 100_00, 1_000_00, 10_000_00, 100_000_00, 100_000_000_00].each do |proposed_goal_cents|
          
          get :calculate_goal_cents, proposed_goal_cents: proposed_goal_cents
          all_response_values_present
          expect(Monetize.parse(the_formatted_total)).to be > Money.new(proposed_goal_cents)
          
        end
        
        # ---
        
        proposed_goal = Money.new(1_000_00)
        total = Money.new(9_123_456_78)
        explanation = SecureRandom.hex(24)
        
        campaign = double(present_calculations: {
          explanation: explanation,
          formatted_total:  total.format(CampaignDraft::FORMAT_OPTS.dup),
          formatted_total_no_symbol: total.format(CampaignDraft::FORMAT_OPTS.dup.merge(symbol: false)),
          cents_total: total.fractional
        })
        
        expect(CampaignDraft).to receive(:new).with({proposed_goal_cents: proposed_goal.fractional.to_s}).and_return(campaign)
        get :calculate_goal_cents, proposed_goal_cents: proposed_goal.fractional
        
        expect(the_cents_total).to eq total.fractional
        expect(Monetize.parse(the_formatted_total).to_i).to eq total.to_i
        expect(Monetize.parse(the_formatted_total_without_symbol).to_i).to eq total.to_i
        expect(the_explanation).to eq explanation
        
        all_response_values_present
        
      end
      
      context 'event_promoter role' do
        
        sign_as :event_promoter
        
        it "works" do
          the_tests
        end
        
      end
      
      context 'admin role' do
        
        sign_as :admin
        
        it "works" do
          the_tests
        end
        
      end
      
    end
    
    
    context 'forbidden roles' do
      
      before {
        expect_unauthorized
        expect(CampaignDraft).to_not receive(:new)
        get :calculate_goal_cents, proposed_goal_cents: 1
      }
      
      forbidden_for(nil, :attendee)
      
    end
      
    
  end
  
end