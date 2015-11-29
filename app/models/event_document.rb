class EventDocument < ActiveRecord::Base
  
  belongs_to :event
  
  validates :event, presence: true
  validates :filename, presence: true
  validates :key, presence: true
  validates :visible_name, presence: true
  
end
