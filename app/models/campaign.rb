class Campaign < ActiveRecord::Base
  
  belongs_to :event_promoter
  has_and_belongs_to_many :attendee, join_table: :pledges
  has_many :pledges
  has_one :event
  
end
