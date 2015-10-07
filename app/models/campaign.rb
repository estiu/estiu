class Campaign < ActiveRecord::Base
  
  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  BASIC_ATTRS = %i(name starts_at ends_at)
  CREATE_ATTRS = BASIC_ATTRS + [:description, :goal_cents]
  
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
  
  validates :description, presence: true, length: {minimum: 140}
  
  attr_accessor :goal_cents_facade
  
end
