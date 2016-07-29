describe "Calculating the actual goal as the user types a proposed goal, on Campaign Draft updating", js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:the_campaign){ FG.create :campaign_draft, event_promoter: event_promoter.event_promoter }
  
  before {
    visit edit_campaign_draft_path(the_campaign)
  }
  
  def the_proposed_goal_field
    find('#campaign_draft_proposed_goal_cents_facade')
  end
  
  def the_actual_goal_indicator
    find('#calculated-goal-cents-indicator')
  end
  
  context "when I visit the page" do
    
    it "the actual goal indicator already has a value present" do
      
      expect(the_actual_goal_indicator.text).to be_present
      
    end
    
  end
  
  context "when I fill the Proposed Goal field again with the same value" do
    
    it "doesn't update the actual goal indicator" do
      
      expect {
        the_proposed_goal_field.set(the_campaign.proposed_goal.format)
        sleep 3
      }.to_not change {
        the_actual_goal_indicator.text
      }
      
    end
    
  end
  
  context "when I fill the Proposed Goal field again a new value" do
    
    it "updates the actual goal indicator" do
      
      expect {
        the_proposed_goal_field.set((the_campaign.proposed_goal * 2).format)
        sleep 3
      }.to change {
        the_actual_goal_indicator.text
      }
      
    end
    
  end
  
end