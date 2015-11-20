class Event < ActiveRecord::Base
  
  has_and_belongs_to_many :ra_artists
  has_and_belongs_to_many :attendees, join_table: :tickets
  belongs_to :campaign
  belongs_to :venue
  has_many :tickets
  
  accepts_nested_attributes_for :ra_artists, allow_destroy: false, reject_if: ->(object){ object[:artist_path].blank? }
  validate :at_least_one_ra_artist
  before_validation :find_ra_paths
  
  # name, starts_at, venue_id are already present in Campaign, but these represent the *definitive* values.
  CREATE_ATTRS = %i(name starts_at duration venue_id)
  
  CREATE_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates_numericality_of :duration, greater_than_or_equal_to: 3600
  
  def self.visible_for_event_promoter event_promoter
    joins(:campaign).where(campaigns: {event_promoter_id: event_promoter.id})
  end
  
  def self.visible_for_attendee attendee
    joins(campaign: :pledges).where(pledges: {attendee_id: attendee.id})
  end
  
  def at_least_one_ra_artist
    if ra_artists.size.zero?
      errors[:ra_artists] << I18n.t("events.errors.at_least_one_ra_artist")
    end
  end
  
  def find_ra_paths
    new_value = self.ra_artists.map do |ra|
      v = RaArtist.where(artist_path: ra.artist_path).first_or_initialize
      v
    end
    association(:ra_artists).send(:through_association).target.clear
    self.ra_artists = new_value
  end
  
  def artists_to_display
    ra_artists.pluck(:artist_name).join(', ')
  end
  
end
