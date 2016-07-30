describe "Calculating the actual goal as the user types a proposed goal, on Campaign Draft updating", js: true do
  
  sign_as :event_promoter, :feature
  
  let!(:the_campaign){ 
    v = FG.create :campaign_draft, event_promoter: event_promoter.event_promoter
    v.generate_goal_cents
    v
  }
  
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
      
      expect(the_actual_goal_indicator.text).to eq(the_campaign.present_calculations.fetch(:explanation))
      
    end
    
  end
  
  context "when I fill the Proposed Goal field again with the same value" do
    
    it "doesn't update the actual goal indicator" do
      
      expect {
        the_proposed_goal_field.set(the_campaign.proposed_goal.format(currency_field_format_opts))
        sleep 3
      }.to_not change {
        the_actual_goal_indicator.text
      }
      
    end
    
  end
  
  context "when I fill the Proposed Goal field again a new value" do
    
    it "updates the actual goal indicator" do
      
      new_value = nil
      
      expect {
        new_value = Money.new(the_campaign.proposed_goal_cents * 2)
        the_proposed_goal_field.set(new_value.format(currency_field_format_opts))
        sleep 3
      }.to change {
        the_actual_goal_indicator.text
      }#.from(old_value).to(->(v){ v == new_value.format(goal_indicator_format_opts) }) # XXX shitty RSpec bug
      
    end
    
  end
  
end