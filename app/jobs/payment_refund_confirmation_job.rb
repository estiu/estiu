class PaymentRefundConfirmationJob < ApplicationJob
  
  def perform pledge_id
    pledge = Pledge.find pledge_id
    PaymentRefundConfirmationMailer.perform(pledge).deliver_later
  end
  
end