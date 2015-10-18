class Campaign < ActiveRecord::Base
  
  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  DATE_ATTRS = %i(starts_at ends_at)
  BASIC_ATTRS = %i(name) + DATE_ATTRS
  CREATE_ATTRS = BASIC_ATTRS + [:description, :goal_cents, :recommended_pledge_cents, :minimum_pledge_cents]
  
  extend ResettableDates
  
  belongs_to :event_promoter
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
  
  BASIC_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates :description, presence: true, length: {minimum: 140, maximum: 1000}
  
  before_validation :assign_recommended_pledge_cents
  
  attr_accessor :goal_cents_facade
  
  def pledged
    (pledged_cents / 100.0).to_money
  end
  
  def percent_pledged
    (pledged_cents.to_f / goal_cents.to_f * 100).round 2
  end
  
  def pledged_cents
    pledges.sum(:amount_cents)
  end
  
  def active?
    (starts_at..ends_at).cover?(Time.zone.now) && !fulfilled?
  end
  
  def fulfilled?
    goal_cents - pledged_cents < minimum_pledge_cents
  end
  
  def recommended_pledge_cents
    attributes['recommended_pledge_cents'] || minimum_pledge_cents
  end
  
  def recommended_pledge_amount_cents # XXX kill this method. or maybe use it to suggest it to promoters. <<<<<<<<<<<<<<<<<<<<<<<<<<<
    goal_cents / [estimated_minimum_pledges, pledges.count].max
  end
  
  def recommended_pledge_amount
    (recommended_pledge_amount_cents / 100.0).to_money
  end
  
  def estimated_minimum_pledges # this field meaning has to be refined
    200
  end
  
  def assign_recommended_pledge_cents # https://github.com/RubyMoney/money-rails/issues/380
    self.recommended_pledge_cents = self.recommended_pledge_cents
  end
  
  def maximum_pledge_cents
    [remaining_amount_cents, Pledge::MAXIMUM_PLEDGE_AMOUNT].min
  end
  
  def remaining_amount_cents
    goal_cents - pledged_cents
  end
  
end
