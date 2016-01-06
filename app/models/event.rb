class Event < ActiveRecord::Base
  
  has_and_belongs_to_many :ra_artists
  has_and_belongs_to_many :attendees, join_table: :tickets
  belongs_to :campaign
  belongs_to :venue
  has_many :tickets
  has_many :event_documents, dependent: :destroy
  
  attr_accessor :documents_confirmation
  
  accepts_nested_attributes_for :ra_artists, allow_destroy: false, reject_if: ->(object){ object[:artist_path].blank? }
  accepts_nested_attributes_for :event_documents, allow_destroy: false, reject_if: ->(object){ object[:filename].blank? }
  validate :at_least_one_ra_artist
  before_validation :find_ra_paths, on: :create
  before_validation :ensure_at_least_one_event_document, if: :submitted_at
  
  # name, starts_at, venue_id are already present in Campaign, but these represent the *definitive* values.
  CREATE_ATTRS = %i(name starts_at duration venue_id)
  
  CREATE_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates_numericality_of :duration, greater_than_or_equal_to: 3600
  validates :submitted_at, presence: true, if: :approved_at
  validates :submitted_at, presence: true, if: :rejected_at
  validates :approved_at, inclusion: [nil], unless: :submitted_at
  validates :approved_at, inclusion: [nil], if: :rejected_at
  validates :rejected_at, inclusion: [nil], unless: :submitted_at
  validates :rejected_at, inclusion: [nil], if: :approved_at
  validate :campaign_was_fulfilled
  validate :approved_at_and_rejected_at_nil_when_submitting
  
  def self.visible_for_event_promoter event_promoter
    joins(:campaign).where(campaigns: {event_promoter_id: event_promoter.id})
  end
  
  def self.visible_for_attendee attendee
    joins(campaign: :pledges).where(pledges: {attendee_id: attendee.id}).where.not(approved_at: nil)
  end
  
  def self.not_celebrated
    where("events.starts_at > ?", DateTime.now)
  end
  
  def must_be_reviewed?
    submitted_at && (!approved_at && !rejected_at)
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
    association(:ra_artists).target.clear
    new_value.each do |ra_artist|
      self.ra_artists << ra_artist
    end
  end
  
  def artists_to_display
    ra_artists.pluck(:artist_name).join(', ')
  end
  
  def ensure_at_least_one_event_document
    if event_documents.size.zero?
      errors[:event_documents] << I18n.t("events.errors.ensure_at_least_one_event_document")
    end
  end
  
  def campaign_was_fulfilled
    unless campaign.fulfilled_at
      errors[:campaign] << 'campaign.fulfilled_at must be present.'
    end
  end
  
  def approved_at_and_rejected_at_nil_when_submitting
    change = previous_changes[:submitted_at]
    if change && change[0].nil? && change[1].present?
      if approved_at
        errors[:approved_at] << 'Cannot be present when setting submitted_at'
      end
      if rejected_at
        errors[:rejected_at] << 'Cannot be present when setting submitted_at'
      end
    end
  end
  
end
