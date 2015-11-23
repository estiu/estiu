class EventDocument < ActiveRecord::Base
  
  belongs_to :event_promoter
  
  validates :event_promoter, presence: true
  
  mount_uploader :filename, BaseUploader
  
end
