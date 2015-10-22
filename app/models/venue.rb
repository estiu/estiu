class Venue < ActiveRecord::Base
  
  has_many :events
  
  CREATE_ATTRS = %i(name address description capacity)
  
  CREATE_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  def self.for_select
    pluck :name, :id
  end
  
  def self.venue_capacities
    Hash[(pluck :id, :capacity)]
  end
  
end
