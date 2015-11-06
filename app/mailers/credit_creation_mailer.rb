class CreditCreationMailer < ApplicationMailer
  
  def perform credit
    @credit = credit
    @amount = credit.amount.format
    @referrer = credit.pledge.attendee.first_name
    mail(to: credit.attendee.user.email, subject: t(".subject", amount: @amount))
  end
  
end