describe "Calculating the actual goal as the user types a proposed goal, on Campaign Draft creating", js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:reference_campaign){ FG.build :campaign_draft }
  
  before {
    visit new_campaign_draft_path
  }
  
  def the_proposed_goal_field
    find('#campaign_draft_proposed_goal_cents_facade')
  end
  
  def the_actual_goal_indicator
    find('#calculated-goal-cents-indicator')
  end
  
  context "when I fill the Proposed Goal field" do
    
    before {
      expect(the_proposed_goal_field.value).to be_blank
    }
    
    it "updates the actual goal indicator" do
      
      expect {
        the_proposed_goal_field.set(reference_campaign.proposed_goal.format)
        sleep 3
      }.to change {
        the_actual_goal_indicator.text.blank?
      }.from(true).to(false)
      
    end
    
  end
  
  context "when I fill the Proposed Goal field again with the same value" do
    
    before {
      the_proposed_goal_field.set(reference_campaign.proposed_goal.format)
      sleep 3
    }
    
    it "doesn't update the actual goal indicator" do
      
      expect {
        the_proposed_goal_field.set(reference_campaign.proposed_goal.format)
        sleep 3
      }.to_not change {
        the_actual_goal_indicator.text
      }
      
    end
    
  end
  
  context "when I fill the Proposed Goal field again a new value" do
    
    before {
      the_proposed_goal_field.set(reference_campaign.proposed_goal.format)
    }
    
    it "updates the actual goal indicator" do
      
      expect {
        the_proposed_goal_field.set((reference_campaign.proposed_goal * 2).format)
        sleep 3
      }.to change {
        the_actual_goal_indicator.text
      }
      
    end
    
  end
  
end