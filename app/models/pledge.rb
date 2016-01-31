class Pledge < ActiveRecord::Base
  
  STRIPE_MINIMUM_PAYMENT = 50
  DISCOUNT_PER_REFERRAL = 200
  MAXIMUM_PLEDGE_AMOUNT = 10_000_00 # KYC
  STRIPE_EUR = 'eur'
  
  has_one :referral_credit, class_name: Credit, foreign_key: :referral_pledge_id
  has_one :refund_credit, class_name: Credit, foreign_key: :refunded_pledge_id
  belongs_to :attendee
  belongs_to :campaign
  validates_presence_of :attendee_id
  validates_presence_of :campaign_id
  
  monetize :originally_pledged_cents # the amount the user originally intended to pay. subject to discounts.
  monetize :discount_cents # the total amount to be discounted.
  monetize :amount_cents # the final amount to be charged. equals originally_pledged_cents - discount_cents
  
  validates :amount_cents, presence: true, numericality: {greater_than_or_equal_to: 1, less_than: MAXIMUM_PLEDGE_AMOUNT}
  # validates :stripe_charge_id, presence: true, if: :id # XXX WRONG: if: :id <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  validates :attendee_id, uniqueness: {scope: :campaign_id}
  
  validates_formatting_of :referral_email, using: :email, allow_blank: true, message: I18n.t('errors.email_format')
  
  validate :minimum_pledge
  validate :check_truthful_referral_email!
  validate :check_valid_desired_credit_ids!, unless: :stripe_charge_id
  
  default_scope { where.not(stripe_charge_id: nil) }
  
  before_validation :nullify_optional_fields
  around_save :maybe_mark_campaign_as_fulfilled
  around_update :create_credits_for_referred_attendee
  
  def self.charge_description_for campaign
    "Pledge for campaign #{campaign.id}"
  end

  def charged?
    stripe_charge_id.present?
  end
  
  def refund_credit_charged?
    Credit.unscoped{ refund_credit }.present?
  end
  
  def refunded?
    reload
    stripe_refund_id.present? || refund_credit_charged?
  end
  
  def refundable?
    return false if stripe_charge_id.blank? # XXX this is incomplete since the pledge could have been paid with no money at all - only credits.
    return false if campaign.active?
    return false if refunded?
    if campaign.unfulfilled_at
      return true
    elsif campaign.fulfilled_at && campaign.event
      return !!campaign.event.rejected_at
    else
      return false
    end
  end
  
  def calculate_discount!
    
    check_truthful_referral_email!(:check_format)
    if referral_email.present? && errors[:referral_email].blank?
      self.discount_cents += DISCOUNT_PER_REFERRAL
    end
    
    credits = check_valid_desired_credit_ids!
    if errors[:desired_credit_ids].blank?
      self.discount_cents += credits.map(&:amount_cents).sum
    end
    
  end
  
  def calculate_total!
    self.calculate_discount!
    self.amount_cents = self.originally_pledged_cents - self.discount_cents
  end
  
  def charge!(token)
    
    raise "charge_id already exists" if stripe_charge_id.present?
    
    valid_credits = nil
    charge = nil
    
    transaction do # note that this is NOT a nested transaction.
      
      credits = check_valid_desired_credit_ids! :do_lock # the locking is only useful if we are locking reads as well, which can only be accomplished by table locking, with the ACCESS EXCLUSIVE option. maybe there's a better approach?
      valid_credits = errors[:desired_credit_ids].blank?
      
      if valid_credits
        charge = Stripe::Charge.create(
          amount: amount_cents,
          currency: STRIPE_EUR,
          source: token,
          description: self.class.charge_description_for(campaign)
        )
        
        Rails.logger.info "Successfully charged pledge with id #{id}. Charge id: #{charge.id}"
        
        credits.each {|credit| credit.update_attributes! charged: true }
      end
      
    end
    
    return false unless valid_credits
    
    self.stripe_charge_id = charge.id
    saved = self.save
    unless saved
      message = "Pledge charge succeeded, but could not update object with id #{self.id}. Errors: #{self.errors.full_messages}"
      Rails.logger.error message
      Rollbar.error message
    end
    return true
    
  rescue Stripe::CardError => e
    Rails.logger.error e.class
    Rails.logger.error e
    Rollbar.error e
    return false
  end
  
  def refund_payment!
    return false unless refundable?
    refund_id = Stripe::Refund.create(charge: stripe_charge_id).id
    Rails.logger.info "Successfully refunded pledge with id #{id}. Refund id: #{refund_id}"
    self.stripe_refund_id = refund_id
    saved = self.save
    if saved
      PaymentRefundConfirmationJob.perform_later self.id
    else
      message = "Pledge refund succeeded, but could not update object with id #{self.id}. Errors: #{self.errors.full_messages}"
      Rails.logger.error message
      Rollbar.error message
    end
    true
  rescue Stripe::InvalidRequestError => e
    Rails.logger.error e.class
    Rails.logger.error e
    Rollbar.error e
    false
  end
  
  def create_refund_credit!
    return false unless refundable?
    credit = Credit.new(amount_cents: amount_cents, refunded_pledge: self, attendee: attendee, charged: false)
    if credit.save
      true
    else
      message = "`create_refund_credit!` failed. Errors: #{credit.errors.full_messages}"
      Rails.logger.error message
      Rollbar.error message
      false
    end
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
  
  def find_credits id_or_ids
    Credit.uncached {
      attendee.credits.find id_or_ids
    }
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
  
  def create_credits_for_referred_attendee
    if referral_email.present?
      change = changes[:stripe_charge_id]
      if change && change[0].nil? && change[1].present?
        attendee_id = User.find_by_email(referral_email).attendee_id
        Credit.create!(charged: false, attendee_id: attendee_id, amount_cents: DISCOUNT_PER_REFERRAL, referral_pledge: self)
      end
    end
    yield
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
  
  def check_valid_desired_credit_ids! do_lock=false
    
    credits = []
    
    (desired_credit_ids || []).each do |id|
      
      credit = nil
      
      begin
        
        credit = find_credits(id)
        credit.lock! if do_lock
        credits << credit
        
      rescue ActiveRecord::RecordNotFound
        
        errors[:desired_credit_ids] << I18n.t("pledges.errors.desired_credit_ids")
        
        return
        
      end
      
    end
    
    return credits
    
  end
  
  def nullify_optional_fields
    unless self.referral_email.present?
      self.referral_email = nil
    end
  end
  
end
