class CreditCreationJob < ApplicationJob
  
  def perform credit_id
    credit = Credit.find credit_id
    CreditCreationMailer.perform(credit).deliver_later
  end
  
end