class Attendee < ActiveRecord::Base
  
  has_and_belongs_to_many :events, join_table: :tickets
  has_and_belongs_to_many :campaigns, join_table: :pledges
  has_many :tickets
  has_many :pledges
  
end
