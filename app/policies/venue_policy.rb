class PledgePolicy < ApplicationPolicy
  
  def create?
    user.event_promoter?
  end

end