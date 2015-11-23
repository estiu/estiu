class EventPolicy < ApplicationPolicy
  
  def new_or_create?
    user.event_promoter? &&
    record.campaign.event_promoter == user.event_promoter &&
    !Event.where(campaign_id: record.campaign.id).exists?
  end
  
  def index?
    user.admin? || user.event_promoter? || user.attendee?
  end
  
  def show?
    if user.admin?
      true
    elsif user.event_promoter?
      scope.visible_for_event_promoter(user.event_promoter).include? record
    elsif user.attendee?
      scope.visible_for_attendee(user.attendee).include? record
    else
      false
    end
  end
  
  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.event_promoter?
        scope.visible_for_event_promoter(user.event_promoter)
      elsif user.attendee?
        scope.visible_for_attendee(user.attendee)
      else
        raise
      end
    end
  end
  
end