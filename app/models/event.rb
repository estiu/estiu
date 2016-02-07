class Event < ActiveRecord::Base
  
  # note on starts_at: It must be timezone-unaware. (Unpredicatble) timezone-related changes should never affect the time the user did specify, for a given event.
  
  has_and_belongs_to_many :ra_artists
  has_and_belongs_to_many :attendees, join_table: :tickets
  belongs_to :campaign
  belongs_to :venue
  has_many :tickets
  has_many :event_documents, dependent: :destroy
  has_one :event_promoter, through: :campaign
  
  attr_accessor :documents_confirmation
  
  accepts_nested_attributes_for :ra_artists, allow_destroy: false, reject_if: ->(object){ object[:artist_path].blank? }
  accepts_nested_attributes_for :event_documents, allow_destroy: false, reject_if: ->(object){ object[:filename].blank? }
  before_validation :find_ra_paths, on: :create
  before_validation :ensure_at_least_one_event_document, if: :submitted_at
  after_commit :on_approval, on: :update
  after_commit :on_rejection, on: :update
  
  # name, starts_at*, venue_id are already present in Campaign, but these represent the *definitive* values.
  CREATE_ATTRS = %i(name starts_at_date starts_at_hours starts_at_minutes duration_hours duration_minutes venue_id)
  MIN_DURATION = 3600
  
  CREATE_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates_numericality_of :starts_at_hours, greater_than_or_equal_to: 0, less_than: 24
  validates_numericality_of :starts_at_minutes, greater_than_or_equal_to: 0, less_than: 60
  validates_numericality_of :duration, greater_than_or_equal_to: MIN_DURATION
  validates :submitted_at, presence: true, if: :approved_at
  validates :submitted_at, presence: true, if: :rejected_at
  validates :approved_at, inclusion: [nil], unless: :submitted_at
  validates :approved_at, inclusion: [nil], if: :rejected_at
  validates :rejected_at, inclusion: [nil], unless: :submitted_at
  validates :rejected_at, inclusion: [nil], if: :approved_at
  
  validate :campaign_was_fulfilled
  validate :approved_at_and_rejected_at_nil_when_submitting
  validate :starts_at_is_future, on: :create
  validate :at_least_one_ra_artist
  
  def self.visible_for_event_promoter event_promoter
    joins(:campaign).where(campaigns: {event_promoter_id: event_promoter.id})
  end
  
  def self.visible_for_attendee attendee
    joins(campaign: :pledges).where(pledges: {attendee_id: attendee.id}).where.not(approved_at: nil)
  end
  
  def self.not_celebrated
    all.select{|event|
      event.starts_at_for_calculations > DateTime.current
    }
  end
  
  def starts_at_for_calculations
    venue.timezone_object.local(starts_at_date.year, starts_at_date.month, starts_at_date.day, starts_at_hours, starts_at_minutes)
  end
  
  def starts_at_for_user # XXX localize date format according to user's preference
    "#{starts_at_date} #{starts_at_hours}:#{starts_at_minutes.to_s.rjust(2, '0')}"
  end
  
  def duration
    (duration_hours || 0).hours + duration_minutes.minutes
  end
  
  def must_be_reviewed?
    submitted_at && (!approved_at && !rejected_at)
  end
  
  {approve!: :approved_at, reject!: :rejected_at}.each do |method, attr|
    define_method method do
      update_attributes!({attr => DateTime.now})
    end
  end
  
  def to_s
    name
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
  
  def at_least_one_ra_artist
    if ra_artists.size.zero?
      errors[:ra_artists] << I18n.t("events.errors.at_least_one_ra_artist")
    end
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
    change = previous_changes[:submitted_at] # XXX is this correct in a `validate`? Its for after_commit I think
    if change && change[0].nil? && change[1].present?
      if approved_at
        errors[:approved_at] << 'Cannot be present when setting submitted_at'
      end
      if rejected_at
        errors[:rejected_at] << 'Cannot be present when setting submitted_at'
      end
    end
  end
  
  def starts_at_is_future
    if starts_at_for_calculations && starts_at_for_calculations.to_i - DateTime.current.to_i < -60
      unless skip_past_date_validations
        errors[:starts_at_date] << I18n.t('past_date')
      end
    end
  end
  
  def on_approval
    change = previous_changes[:approved_at]
    if change && change[0].nil? && change[1].present?
      Events::Approval::TicketCreationJob.perform_later id
      Events::Approval::EventPromoterNotificationJob.perform_later id
    end
  end
  
  def on_rejection
    change = previous_changes[:rejected_at]
    if change && change[0].nil? && change[1].present?
      Events::Rejection::EventPromoterNotificationJob.perform_later id
      Events::Rejection::AttendeeNotificationJob.perform_later id
      campaign.update_attributes!(event_rejected_at: DateTime.now)
    end
  end
  
end
