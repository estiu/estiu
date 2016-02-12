class CampaignDraft < ActiveRecord::Base
  
  belongs_to :venue
  belongs_to :event_promoter
  has_one :campaign

  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  DATE_ATTRS = %i(starts_at ends_at)
  CREATE_ATTRS_STEP_1 = %i(name description venue_id goal_cents minimum_pledge_cents) 
  CREATE_ATTRS_STEP_2 = DATE_ATTRS + %i(starts_immediately time_zone visibility generate_invite_link)
  FORWARD_METHODS = %i(
    starts_at_criterion
    skip_past_date_validations
    venue
    event_promoter
    goal
    invite_token
    minimum_pledge
  )
  PUBLIC_VISIBILITY = 'public'
  APP_VISIBILITY = 'app'
  INVITE_VISIBILITY = 'invite'
  VISIBILITIES = [APP_VISIBILITY, INVITE_VISIBILITY, PUBLIC_VISIBILITY]
  
  extend ResettableDates
  
  monetize :goal_cents, subunit_numericality: {
    greater_than_or_equal_to: MINIMUM_GOAL_AMOUNT,
    less_than: MAXIMUM_GOAL_AMOUNT,
    message: I18n.t("money_range", min: Money.new(MINIMUM_GOAL_AMOUNT).format, max: Money.new(MAXIMUM_GOAL_AMOUNT).format)
  }
  
  monetize :minimum_pledge_cents, subunit_numericality: {
    more_than: Pledge::STRIPE_MINIMUM_PAYMENT,
    less_than: Pledge::MAXIMUM_PLEDGE_AMOUNT
  }
  
  monetize :estimated_minimum_pledge_cents
  
  (CREATE_ATTRS_STEP_1 - %i(description)).each do |attr|
    validates attr, presence: true
  end

  validates :event_promoter, presence: true
  validates :invite_token, presence: true, if: :generate_invite_link
  validates :invite_token, inclusion: [nil], unless: :generate_invite_link
  validates :description, presence: true, length: {minimum: 140, maximum: 1000}
  validates :starts_at, inclusion: [nil], if: :starts_immediately
  validates :submitted_at, presence: true, if: ->(rec){ CREATE_ATTRS_STEP_2.any?{|attr| rec.send(attr).present? } }
  validates :submitted_at, inclusion: [nil], if: ->(rec){ dev_or_test? ? false : rec.id }
  
  begin # validations enclosed in this black depend on :submitted_at
    validates :starts_immediately, inclusion: {in: [true, false], message: I18n.t('errors.inclusion')}, if: :submitted_at
    validates :starts_at, presence: true, if: ->(rec){ rec.submitted_at && !rec.starts_immediately }
    validates :ends_at, presence: true, if: :submitted_at
    validates :time_zone, presence: true, inclusion: {in: Estiu::Timezones::ALL, message: I18n.t('errors.inclusion')}, if: :submitted_at
    validates :visibility, inclusion: {in: VISIBILITIES, message: I18n.t('errors.inclusion')}, if: :submitted_at
    validates :generate_invite_link, inclusion: {in: [true, false], message: I18n.t('errors.inclusion')}, if: :submitted_at
    validates :generate_invite_link,
      inclusion: {in: [true], message: I18n.t('campaigns.errors.generate_invite_link')},
      if: ->(record){
        record.submitted_at &&
        record.generate_invite_link == false && # check false, not nil
        record.visibility == INVITE_VISIBILITY
      }
    validates :generate_invite_link,
      inclusion: {in: [false], message: I18n.t('campaigns.errors.generate_invite_link_false')},
      if: ->(record){
        record.submitted_at &&
        record.generate_invite_link &&
        record.visibility == PUBLIC_VISIBILITY
      }
  end

  validate :valid_date_fields, on: :create
  validate :minimum_pledge_according_to_venue, on: :create

  before_validation :do_generate_invite_link
  before_validation :maybe_discard_starts_at

  attr_accessor :goal_cents_facade
  
  def self.approved
    where.not(approved_at: nil)
  end
  
  def self.rejected
    where.not(rejected_at: nil)
  end
  
  def self.visibility_select
    VISIBILITIES.map{|value|
      [I18n.t("campaigns.form.#{value}_visibility"), value]
    }
  end
  
  def self.minimum_active_hours
    1
  end
  
  def starts_at_criterion
    starts_immediately ? created_at : starts_at
  end
  
  def do_generate_invite_link
    if generate_invite_link && changes[:generate_invite_link]
      self.invite_token = SecureRandom.hex(6)
    end
  end
  
  def maybe_discard_starts_at
    if self.starts_immediately
      self.starts_at = nil
    end
  end
  
  def valid_date_fields
    if starts_at && ends_at
      if starts_at > ends_at
        errors[:starts_at] << I18n.t('campaigns.errors.starts_at.ends_at')
      end
      if ends_at.to_i - starts_at.to_i < self.class.minimum_active_hours.hours
        unless Rails.env.production? && DeveloperMachine.running_in_developer_machine? # sometimes one runs production in a developer machine.
          errors[:ends_at] << I18n.t('campaigns.errors.ends_at.starts_at', hours: self.class.minimum_active_hours)
        end
      end
    end
    if (dev_or_test? ? !skip_past_date_validations : true)
      if starts_at && starts_at.to_i - DateTime.current.to_i < -60
        errors[:starts_at] << I18n.t('past_date')
      end
      if ends_at && ends_at.to_i - DateTime.current.to_i < -60
        errors[:ends_at] << I18n.t('past_date')
      end
    end
  end
  
  def minimum_pledge_according_to_venue
    if minimum_pledge_cents && goal_cents && venue
      if minimum_pledge_cents < estimated_minimum_pledge_cents
        errors[:minimum_pledge_cents] << I18n.t("campaigns.errors.minimum_pledge_cents.venue", value: estimated_minimum_pledge.format)
      end
    end
  end
  
  def estimated_minimum_pledge_cents
    if venue
      goal_cents / venue.capacity
    else
      nil
    end
  end
  
end
