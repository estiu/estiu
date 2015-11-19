class EventPolicy < ApplicationPolicy
  
  def index?
    user.admin? || user.event_promoter? || user.attendee?
  end
  
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.event_promoter?
        scope.joins(:campaign).where(campaigns: {event_promoter_id: user.event_promoter.id})
      elsif user.attendee?
        scope.joins(campaign: :pledges).where(pledges: {attendee_id: user.attendee.id})
      else
        raise
      end
    end
  end
  
end