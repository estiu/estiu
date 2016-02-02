class PledgePolicy < ApplicationPolicy
  
  def update?
    can_touch? && !user.attendee.pledged?(record.campaign)
  end
  
  def charge?
    can_touch? && !record.charged?
  end
  
  def refund_payment?
    refundable?
  end
  
  def create_refund_credit?
    refundable?
  end
  
  private
  
  def refundable?
    _common && !record.refunded?
  end
  
  def _common
    user.attendee?
  end
  
  def can_touch?
    _common && record.campaign.active? && (user == record.attendee.user)
  end

end