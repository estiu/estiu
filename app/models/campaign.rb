class Campaign < ActiveRecord::Base
  
  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  DATE_ATTRS = %i(starts_at ends_at)
  BASIC_ATTRS = %i(name) + DATE_ATTRS
  CREATE_ATTRS = BASIC_ATTRS + [:description, :goal_cents, :recommended_pledge_cents, :minimum_pledge_cents, :venue_id]
  
  extend ResettableDates
  
  belongs_to :event_promoter
  belongs_to :venue
  has_and_belongs_to_many :attendees, join_table: :pledges
  has_many :pledges
  has_one :event
  
  monetize :goal_cents, subunit_numericality: {
    greater_than_or_equal_to: MINIMUM_GOAL_AMOUNT,
    less_than: MAXIMUM_GOAL_AMOUNT,
    message: I18n.t("money_range", min: Money.new(MINIMUM_GOAL_AMOUNT).format, max: Money.new(MAXIMUM_GOAL_AMOUNT).format)
  }
  
  monetize :recommended_pledge_cents, subunit_numericality: {
    allow_nil: true,
    less_than: Pledge::MAXIMUM_PLEDGE_AMOUNT
  }
  
  monetize :minimum_pledge_cents, subunit_numericality: {
    less_than: Pledge::MAXIMUM_PLEDGE_AMOUNT
  }
  
  monetize :pledged_cents
  monetize :estimated_minimum_pledge_cents
  
  BASIC_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates :description, presence: true, length: {minimum: 140, maximum: 1000}
  
  validate :valid_date_fields
  validate :minimum_pledge_according_to_venue, on: :create
  
  before_validation :assign_recommended_pledge_cents
  
  attr_accessor :goal_cents_facade
  
  def self.minimum_active_hours
    1
  end
  
  def percent_pledged
    (pledged_cents.to_f / goal_cents.to_f * 100).round 2
  end
  
  def pledged_cents
    Pledge.uncached {
      pledges.sum(:amount_cents)
    }
  end
  
  def active?
    active_time = Rails.env.test? && skip_past_date_validations ? true : (starts_at..ends_at).cover?(Time.zone.now)
    active_time && !fulfilled?
  end
  
  def fulfilled?
    goal_cents - pledged_cents < minimum_pledge_cents
  end
  
  def recommended_pledge_cents
    attributes['recommended_pledge_cents'] || minimum_pledge_cents
  end
  
  def assign_recommended_pledge_cents # workaround RubyMoney issue which I wasn't able to reproduce in isolation.
    self.recommended_pledge_cents = self.recommended_pledge_cents
  end
  
  def maximum_pledge_cents
    [remaining_amount_cents, Pledge::MAXIMUM_PLEDGE_AMOUNT].min
  end
  
  def remaining_amount_cents
    v = goal_cents - pledged_cents
    v < 0 ? 0 : v # should never be < 0, but better safe than sorry
  end
  
  def valid_date_fields
    if starts_at && ends_at
      if starts_at > ends_at
        errors[:starts_at] << I18n.t('campaigns.errors.starts_at.ends_at')
      end
      if ends_at.to_i - starts_at.to_i < self.class.minimum_active_hours.hours
        errors[:ends_at] << I18n.t('campaigns.errors.ends_at.starts_at', hours: self.class.minimum_active_hours)
      end
    end
    if (dev_or_test? ? !skip_past_date_validations : true)
      if starts_at && starts_at.to_i - Time.zone.now.to_i < -60
        errors[:starts_at] << I18n.t('past_date')
      end
      if ends_at && ends_at.to_i - Time.zone.now.to_i < -60
        errors[:ends_at] << I18n.t('past_date')
      end
    end
  end
  
  def estimated_minimum_pledge_cents
    goal_cents / venue.capacity
  end
  
  def minimum_pledge_according_to_venue
    if minimum_pledge_cents && goal_cents && venue
      if minimum_pledge_cents < estimated_minimum_pledge_cents
        errors[:minimum_pledge_cents] << I18n.t("campaigns.errors.minimum_pledge_cents.venue", value: estimated_minimum_pledge.format)
      end
    end
  end
  
end
