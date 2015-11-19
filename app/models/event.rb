class Event < ActiveRecord::Base
  
  has_and_belongs_to_many :artists
  has_and_belongs_to_many :attendees, join_table: :tickets
  belongs_to :campaign
  belongs_to :venue
  has_many :tickets
  
  %i(name starts_at duration).each do |attr|
    validates attr, presence: true
  end
  
  def self.visible_for_event_promoter event_promoter
    joins(:campaign).where(campaigns: {event_promoter_id: event_promoter.id})
  end
  
  def self.visible_for_attendee attendee
    joins(campaign: :pledges).where(pledges: {attendee_id: attendee.id})
  end
  
end
