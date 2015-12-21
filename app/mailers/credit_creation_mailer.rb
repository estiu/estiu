class CreditCreationMailer < ApplicationMailer
  
  def perform credit
    @credit = credit
    @amount = credit.amount.format
    @type = credit.referral_pledge ? :referral_pledge : credit.refunded_pledge ? :refunded_pledge : raise
    if credit.referral_pledge
      @referrer = credit.referral_pledge.attendee.first_name
    elsif credit.refunded_pledge
      # nothing
    else
      raise
    end
    mail(to: credit.attendee.user.email, subject: t(".subject", amount: @amount))
  end
  
end