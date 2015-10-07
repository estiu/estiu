class Pledge < ActiveRecord::Base
  
  MAXIMUM_PLEDGE_AMOUNT = 10_000_00 # KYC
  
  belongs_to :attendee
  belongs_to :campaign
  
  monetize :amount_cents
  
  validates :amount_cents, presence: true, numericality: {greater_than_or_equal_to: 1, less_than: MAXIMUM_PLEDGE_AMOUNT}
  
end
