class Venue < ActiveRecord::Base
  
  has_many :events
  has_many :campaign_drafts
  has_many :campaigns, through: :campaign_drafts
  
  CREATE_ATTRS = %i(name address description capacity)
  
  CREATE_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates :name, uniqueness: true
  
  def self.with_active_campaigns
    ids = CampaignDraft.
      joins(:campaign).
      where(campaigns: {fulfilled_at: nil, unfulfilled_at: nil}).
      where("starts_at <= ?", DateTime.current).
      where("ends_at >= ?", DateTime.current).
      pluck(:venue_id).
      uniq
    Venue.find ids
  end
  
  def self.for_select
    pluck :name, :id
  end
  
  def self.venue_capacities
    Hash[(pluck :id, :capacity)]
  end
  
  def to_s
    name
  end
  
  def timezone_object
    Time.zone # XXX ActiveSupport::TimeZone.find city.timezone
  end
  
end
