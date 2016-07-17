class VenuePolicy < ApplicationPolicy
  
  def new_or_create?
    user.event_promoter? || user.admin?
  end

end