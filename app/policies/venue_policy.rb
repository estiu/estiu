class VenuePolicy < ApplicationPolicy
  
  def index?
    logged_in?
  end
  
  def new_or_create?
    user.event_promoter? || user.admin?
  end
  
  class Scope < Scope
    def resolve
      if VenuePolicy.new(user, nil).new_or_create?
        scope.all
      elsif user.attendee?
        scope.with_active_campaigns
      else
        raise
      end
    end
  end
  
end