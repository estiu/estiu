describe CalculationsController do
  
  describe '#calculate_goal_cents' do
    
    def the_formatted_value
      JSON.parse(response.body).fetch 'formatted_value'
    end
    
    def the_formatted_value_without_symbol
      JSON.parse(response.body).fetch 'formatted_value_no_symbol'
    end
    
    def the_cents_value
      JSON.parse(response.body).fetch 'cents_value'
    end
    
    def all_three_values_present
      [the_formatted_value, the_formatted_value_without_symbol, the_cents_value].each do |value|
        expect(value).to be_present
      end
    end
    
    describe 'permitted roles' do
      
      after do
        controller_ok
      end
      
      def the_tests
        
        get :calculate_goal_cents, proposed_goal_cents: 0
        all_three_values_present
        expect(Monetize.parse(the_formatted_value).to_i).to eq 0
        
        # ---
        
        get :calculate_goal_cents, proposed_goal_cents: 1
        all_three_values_present
        
        # ---
        
        [1_00, 100_00, 1_000_00, 10_000_00, 100_000_00, 100_000_000_00].each do |proposed_goal_cents|
          
          get :calculate_goal_cents, proposed_goal_cents: proposed_goal_cents
          all_three_values_present
          expect(Monetize.parse(the_formatted_value)).to be > Money.new(proposed_goal_cents)
          
        end
        
        # ---
        
        proposed_goal_cents = 1_000_00
        goal = Money.new(9_123_456_78)
        campaign = double(generate_goal_cents: nil, goal: goal)
        expect(CampaignDraft).to receive(:new).with({proposed_goal_cents: proposed_goal_cents.to_s}).and_return(campaign)
        get :calculate_goal_cents, proposed_goal_cents: proposed_goal_cents
        expect(Monetize.parse(the_formatted_value).to_i).to eq goal.to_i
        all_three_values_present
        
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