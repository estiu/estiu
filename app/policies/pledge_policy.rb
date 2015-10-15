class PledgePolicy < ApplicationPolicy
  
  def create?
    user.attendee? && record.campaign.active? && !user.attendee.pledged?(record.campaign)
  end
  
end