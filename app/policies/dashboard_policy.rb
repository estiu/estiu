class DashboardPolicy < ApplicationPolicy
  
  def index?
    logged_in? && (user.event_promoter? || user.admin?)
  end
  
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.event_promoter?
        scope.visible_for_event_promoter(user.event_promoter)
      else
        raise
      end
    end
  end
  
  def self.policy_class
    self
  end
  
end