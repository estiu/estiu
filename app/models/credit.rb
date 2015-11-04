class Credit < ActiveRecord::Base
  
  belongs_to :attendee
  
  default_scope { where charged: false }
  
  after_commit :notify_attendee
  
  def notify_attendee
    
  end
  
end
