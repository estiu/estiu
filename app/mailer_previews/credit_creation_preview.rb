class CreditCreationPreview < ActionMailer::Preview
  
  def referral_pledge
    credit = Credit.where.not(referral_pledge_id: nil).first
    unless credit
      credit = FG.create :credit, :referral
    end
    CreditCreationMailer.perform credit
  end
  
  def refunded_pledge
    credit = Credit.where.not(refunded_pledge_id: nil).first
    unless credit
      credit = FG.create :credit, :refund
    end
    CreditCreationMailer.perform credit
  end
  
end