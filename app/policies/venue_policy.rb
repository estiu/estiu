class PledgePolicy < ApplicationPolicy
  
  def new_or_create?
    user.event_promoter?
  end

end