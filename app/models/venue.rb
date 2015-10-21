class Venue < ActiveRecord::Base
  
  has_many :events
  
  %i(name address description capacity).each do |attr|
    validates attr, presence: true
  end
  
end
