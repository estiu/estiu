class Event < ActiveRecord::Base
  
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :attendees, join_table: :tickets
  belongs_to :campaign
  belongs_to :venue
  has_many :tickets
  
  %i(name starts_at duration).each do |attr|
    validates attr, presence: true
  end
  
end
