class Pledge < ActiveRecord::Base
  
  belongs_to :attendee
  belongs_to :campaign
  
end
