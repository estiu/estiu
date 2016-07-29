class CalculationsPolicy < ApplicationPolicy
  
  def calculate_goal_cents?
    logged_in? && (user.event_promoter? || user.admin?)
  end
  
  def self.policy_class
    self
  end
  
end