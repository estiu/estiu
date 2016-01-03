class PledgePolicy < ApplicationPolicy
  
  def new_or_create?
    can_participate? && !user.attendee.pledged?(record.campaign)
  end
  
  def update?
    can_participate? && user == record.attendee.user && !record.charged?
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
  
  def can_participate?
    _common && record.campaign.active?
  end

end