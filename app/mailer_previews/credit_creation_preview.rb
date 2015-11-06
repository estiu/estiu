class CreditCreationPreview < ActionMailer::Preview
  
  def perform
    CreditCreationMailer.perform(Credit.unscoped.first)
  end
  
end