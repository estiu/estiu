class PaymentRefundConfirmationMailer < ApplicationMailer
  
  def perform pledge
    @pledge = pledge
    @amount = pledge.amount.format
    mail(to: pledge.attendee.user.email, subject: t(".subject", amount: @amount))
  end
  
end