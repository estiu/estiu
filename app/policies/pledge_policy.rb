class PledgePolicy < ApplicationPolicy
  
  def new_or_create?
    common && !user.attendee.pledged?(record.campaign)
  end
  
  def update?
    common && user == record.attendee.user && !record.charged?
  end
  
  def refund_payment?
    refundable?
  end
  
  def create_refund_credit
    refundable?
  end
  
  private
  
  def refundable?
    _common && !record.refunded?
  end
  
  def _common
    user.attendee?
  end
  
  def common
    _common && record.campaign.active?
  end

end