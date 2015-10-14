class Campaign < ActiveRecord::Base
  
  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  DATE_ATTRS = %i(starts_at ends_at)
  BASIC_ATTRS = %i(name) + DATE_ATTRS
  CREATE_ATTRS = BASIC_ATTRS + [:description, :goal_cents]
  
  extend ResettableDates
  
  belongs_to :event_promoter
  has_and_belongs_to_many :attendees, join_table: :pledges
  has_many :pledges
  has_one :event
  
  monetize :goal_cents, subunit_numericality: {
    greater_than_or_equal_to: MINIMUM_GOAL_AMOUNT,
    less_than: MAXIMUM_GOAL_AMOUNT,
    message: I18n.t("money_range", min: Money.new(MINIMUM_GOAL_AMOUNT).format, max: Money.new(MAXIMUM_GOAL_AMOUNT).format),
  }
  
  BASIC_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates :description, presence: true, length: {minimum: 140, maximum: 1000}
  
  attr_accessor :goal_cents_facade
  
  def pledged
    pledged_cents.to_money
  end
  
  def percent_pledged
    (pledged_cents.to_f / goal_cents.to_f * 100).round 2
  end
  
  def pledged_cents
    pledges.sum(:amount_cents)
  end
  
end
