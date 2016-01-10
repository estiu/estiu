class Ticket < ActiveRecord::Base
  
  belongs_to :attendee
  belongs_to :event
  
  validates :attendee, presence: true
  validates :event, presence: true
  
end
