class Pledge < ActiveRecord::Base
  
  STRIPE_MINIMUM_PAYMENT = 50
  DISCOUNT_PER_REFERRAL = 200
  MAXIMUM_PLEDGE_AMOUNT = 10_000_00 # KYC
  STRIPE_EUR = 'eur'
  
  belongs_to :attendee
  belongs_to :campaign
  validates_presence_of :attendee_id
  validates_presence_of :campaign_id
  
  monetize :originally_pledged_cents # the amount the user originally intended to pay. subject to discounts.
  monetize :discount_cents # the total amount to be discounted.
  monetize :amount_cents # the final amount to be charged. equals originally_pledged_cents - discount_cents
  
  validates :amount_cents, presence: true, numericality: {greater_than_or_equal_to: 1, less_than: MAXIMUM_PLEDGE_AMOUNT}
  validates :stripe_charge_id, presence: true, if: :id
  
  validates_formatting_of :referral_email, using: :email, allow_blank: true, message: I18n.t('errors.email_format')
  
  validate :minimum_pledge
  validate :check_truthful_referral_email!
  
  default_scope { where.not(stripe_charge_id: nil) }
  
  before_validation :nullify_optional_fields
  around_save :maybe_mark_campaign_as_fulfilled
  
  def self.charge_description_for campaign
    "Pledge for campaign #{campaign.id}"
  end

  def charged?
    stripe_charge_id.present?
  end
  
  def calculate_discount!
    check_truthful_referral_email!(:check_format)
    if referral_email.present? && errors[:referral_email].blank?
      self.discount_cents = DISCOUNT_PER_REFERRAL
    end
  end
  
  def calculate_total!
    self.calculate_discount!
    self.amount_cents = self.originally_pledged_cents - self.discount_cents
  end
  
  def charge!(token)
    charge = Stripe::Charge.create(
      amount: amount_cents,
      currency: STRIPE_EUR,
      source: token,
      description: self.class.charge_description_for(campaign)
    )
    # past this point, the .charge call did't raise anything, that means the charge itself succeeded.
    self.stripe_charge_id = charge.id
    saved = self.save
    Rails.logger.info "Successfully charged a pledge. Charge id: #{charge.id}"
    unless saved
      Rails.logger.error "Pledge charge succeeded, but could not update object #{self}."
    end
    return true
  rescue Stripe::CardError => e
    Rails.logger.error e.class
    Rails.logger.error e
    return false
  end
  
  def discounted_message
    if discount_cents > 0
      I18n.t("pledges.discounted_message", discount: discount.format)
    end
  end
  
  def self.discount_per_referral
    Money.new(DISCOUNT_PER_REFERRAL)
  end
  
  def observed_value_for_minimum_pledge
    amount_cents + discount_cents # this equals to originally_pledged_cents, but it might not in the future (due to taxes or changes in the business model)
  end
  
  def minimum_pledge
    if observed_value_for_minimum_pledge < campaign.minimum_pledge_cents
      errors[:amount_cents] << I18n.t("pledges.errors.amount_cents.minimum_pledge", amount: campaign.minimum_pledge.format)
    end
  end
  
  def maybe_mark_campaign_as_fulfilled
    yield
    campaign.maybe_mark_as_fulfilled
  end
  
  def check_truthful_referral_email! check_format=false
    
    if referral_email.present?
      
      self._validators[:referral_email].each{|v| v.validate self } if check_format # trigger email validation
      
      if errors[:referral_email].blank? # avoid query for non-emails
        
        unless campaign.user_email_pledged? referral_email
          
          errors[:referral_email] << I18n.t("pledges.errors.referral_email.no_user")
          
        end
        
      end
      
    end
    
  end
  
  def nullify_optional_fields
    unless self.referral_email.present?
      self.referral_email = nil
    end
  end
  
end
