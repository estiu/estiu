class PledgePolicy < ApplicationPolicy
  
  def create?
    common && !user.attendee.pledged?(record.campaign)
  end
  
  def update?
    common && user == record.attendee.user && !record.charged?
  end
  
  private
  
  def common
    user.attendee? && record.campaign.active?
  end

end