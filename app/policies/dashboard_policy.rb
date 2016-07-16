class DashboardPolicy < ApplicationPolicy
  
  def index?
    user.event_promoter? || user.admin?
  end
  
  class Scope < Scope
    def resolve
      if user.admin?
        scope
      elsif user.event_promoter?
        scope.joins(:campaign_draft).where(campaign_drafts: {event_promoter_id: user.event_promoter_id})
      else
        raise
      end
    end
  end
  
  def self.policy_class
    self
  end
  
end