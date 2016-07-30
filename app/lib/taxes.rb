class Taxes
  
  SPAIN_RATE = 0.21
  
  class CommissionsNotCalculated < StandardError; end
  
  def self.calculate_for campaign_draft
    base = campaign_draft.goal_cents # calculate the total over goal_cents, not proposed_goal_cents. assumes Commissions.calculate_for as already been invoked.
    raise CommissionsNotCalculated if base.blank?
    rate = SPAIN_RATE # it could be dynamically chosen in the future.
    (base.to_f * rate).to_i
  end
  
end