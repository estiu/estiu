class Pledge < ActiveRecord::Base
  
  STRIPE_MINIMUM_PAYMENT = 50
  MAXIMUM_PLEDGE_AMOUNT = 10_000_00 # KYC
  STRIPE_EUR = 'eur'
  
  belongs_to :attendee
  belongs_to :campaign
  validates_presence_of :attendee_id
  validates_presence_of :campaign_id
  
  monetize :amount_cents
  
  validates :amount_cents, presence: true, numericality: {greater_than_or_equal_to: 1, less_than: MAXIMUM_PLEDGE_AMOUNT}
  validates :stripe_charge_id, presence: true, if: :id
  
  validates_formatting_of :referral_email, using: :email, allow_blank: true, message: I18n.t('errors.email_format')
  
  validate :minimum_pledge
  validate :truthful_referral_email
  
  default_scope { where.not(stripe_charge_id: nil) }
  
  around_save :maybe_mark_campaign_as_fulfilled
  
  def self.charge_description_for campaign
    "Pledge for campaign #{campaign.id}"
  end

  def charged?
    stripe_charge_id.present?
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
  
  def minimum_pledge
    if amount_cents < campaign.minimum_pledge_cents
      errors[:amount_cents] << I18n.t("pledges.errors.amount_cents.minimum_pledge", amount: campaign.minimum_pledge.format)
    end
  end
  
  def maybe_mark_campaign_as_fulfilled
    yield
    campaign.maybe_mark_as_fulfilled
  end
  
  def truthful_referral_email
    if referral_email.present? && errors[:referral_email].blank? # avoid query for non-emails
      unless campaign.user_email_pledged? referral_email
        errors[:referral_email] << I18n.t("pledges.errors.referral_email.no_user")
      end
    end
  end
  
end
