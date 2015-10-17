class Pledge < ActiveRecord::Base
  
  MAXIMUM_PLEDGE_AMOUNT = 10_000_00 # KYC
  STRIPE_EUR = 'eur'
  
  belongs_to :attendee
  belongs_to :campaign
  validates_presence_of :attendee_id
  validates_presence_of :campaign_id
  
  monetize :amount_cents
  
  validates :amount_cents, presence: true, numericality: {greater_than_or_equal_to: 1, less_than: MAXIMUM_PLEDGE_AMOUNT}
  
  def create_by_charging(token)
    return false unless self.valid?
    charge = Stripe::Charge.create(
      amount: amount_cents,
      currency: STRIPE_EUR,
      source: token,
      description: self.class.charge_description_for(campaign)
    )
    # passed this point, the .charge call did't raise anything, that means the charge itself succeeded.
    self.stripe_charge_id = charge.id
    self.save
    Rails.logger.info "Successfully charged a pledge. Charge id: #{charge.id}"
    unless self.persisted?
      Rails.logger.error "Pledge charge succeeded, but could not persist object #{self}."
    end
    return true
  rescue Stripe::CardError => e
    Rails.logger.error e
    return false
  end
  
  def self.charge_description_for campaign
    "Pledge for campaign #{campaign.id}"
  end
  
end
