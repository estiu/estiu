class PaymentRefundConfirmationPreview < ActionMailer::Preview
  
  def perform
    credit = Credit.where.not(referral_pledge_id: nil).first
    pledge = Pledge.where.not(stripe_refund_id: nil).first
    unless pledge
      pledge = FG.create :pledge, :payment_refunded
    end
    PaymentRefundConfirmationMailer.perform pledge
  end
  
end