class Campaign < ActiveRecord::Base
  
  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  BASIC_ATTRS = %i(name description starts_at ends_at)
  CREATE_ATTRS = BASIC_ATTRS + [:goal_cents]
  
  belongs_to :event_promoter
  has_and_belongs_to_many :attendees, join_table: :pledges
  has_many :pledges
  has_one :event
  
  BASIC_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates :goal_cents, presence: true, numericality: {greater_than_or_equal_to: MINIMUM_GOAL_AMOUNT, less_than: MAXIMUM_GOAL_AMOUNT}
  
end
