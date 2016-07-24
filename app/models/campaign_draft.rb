class CampaignDraft < ActiveRecord::Base
  
  extend Approvable
  
  belongs_to :venue
  belongs_to :event_promoter
  has_one :campaign

  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  DATE_ATTRS = %i(starts_at ends_at)
  CREATE_ATTRS_STEP_1 = %i(name description venue_id goal_cents minimum_pledge_cents cost_justification)
  CREATE_ATTRS_STEP_2 = DATE_ATTRS + %i(starts_immediately time_zone visibility generate_invite_link estimated_event_date estimated_event_hour estimated_event_minutes)
  FORWARD_METHODS = %i(
    starts_at_criterion
    skip_past_date_validations
    venue
    event_promoter
    goal
    invite_token
    minimum_pledge
  )
  PUBLIC_VISIBILITY = 'public'
  APP_VISIBILITY = 'app'
  INVITE_VISIBILITY = 'invite'
  VISIBILITIES = [APP_VISIBILITY, INVITE_VISIBILITY, PUBLIC_VISIBILITY]
  GOAL_TO_MINIMUM_PLEDGE_FACTOR = 10 # goal must be at least 10 times higher than the minimum pledge, so at least 10 people can attend.
  
  extend ResettableDates
  
  monetize :goal_cents, subunit_numericality: {
    greater_than_or_equal_to: MINIMUM_GOAL_AMOUNT,
    less_than: MAXIMUM_GOAL_AMOUNT,
    message: I18n.t!("money_range", min: Money.new(MINIMUM_GOAL_AMOUNT).format, max: Money.new(MAXIMUM_GOAL_AMOUNT).format)
  }
  
  monetize :minimum_pledge_cents, subunit_numericality: {
    more_than: Pledge::STRIPE_MINIMUM_PAYMENT,
    less_than: Pledge::MAXIMUM_PLEDGE_AMOUNT
  }
  
  monetize :estimated_minimum_pledge_cents
  
  (CREATE_ATTRS_STEP_1 - %i(description cost_justification)).each do |attr|
    validates attr, presence: true
  end

  validates :event_promoter, presence: true
  validates :invite_token, presence: true, if: :generate_invite_link
  validates :invite_token, inclusion: [nil], unless: :generate_invite_link
  validates :description, presence: true, length: {minimum: (Rails.env.development? ? 2 : 140), maximum: 1000}
  validates :cost_justification, presence: true, length: {minimum: (Rails.env.development? ? 2 : 140), maximum: 1000}
  validates :starts_at, inclusion: [nil], if: :starts_immediately
  validates :published_at, presence: true, if: ->(rec){ (CREATE_ATTRS_STEP_2 - %i(estimated_event_minutes)).any?{|attr| rec.send(attr).present? } }
  validates :published_at, inclusion: [nil], if: ->(rec){ Rails.env.production? ? !rec.id : false }
  validates :submitted_at, inclusion: [nil], if: ->(rec){ Rails.env.production? ? !rec.id : false }
  
  begin # validations enclosed in this black depend on :published_at
    validates :starts_immediately, inclusion: {in: [true, false], message: I18n.t!('errors.inclusion')}, if: :published_at
    validates :starts_at, presence: true, if: ->(rec){ rec.published_at && !rec.starts_immediately }
    validates :ends_at, presence: true, if: :published_at
    validates :campaign, presence: true, if: :published_at
    validates :estimated_event_date, presence: true, if: :published_at
    validates :estimated_event_hour, presence: true, if: :published_at
    validates :estimated_event_minutes, presence: true, if: :published_at
    validates :time_zone, presence: true, inclusion: {in: Estiu::Timezones::ALL, message: I18n.t!('errors.inclusion')}, if: :published_at
    validates :visibility, inclusion: {in: VISIBILITIES, message: I18n.t!('errors.inclusion')}, if: :published_at
    validates :generate_invite_link, inclusion: {in: [true, false], message: I18n.t!('errors.inclusion')}, if: :published_at
    validates :generate_invite_link,
      inclusion: {in: [true], message: I18n.t!('campaigns.errors.generate_invite_link')},
      if: ->(record){
        record.published_at &&
        record.generate_invite_link == false && # check false, not nil
        record.visibility == INVITE_VISIBILITY
      }
    validates :generate_invite_link,
      inclusion: {in: [false], message: I18n.t!('campaigns.errors.generate_invite_link_false')},
      if: ->(record){
        record.published_at &&
        record.generate_invite_link &&
        record.visibility == PUBLIC_VISIBILITY
      }
  end

  validate :valid_date_fields
  validate :minimum_pledge_according_to_venue
  validate :minimum_pledge_not_greater_than_goal

  before_validation :do_generate_invite_link
  before_validation :maybe_discard_starts_at

  attr_accessor :goal_cents_facade
  
  before_validation :create_campaign
  
  def self.without_campaign
    joins('left outer join campaigns on campaign_drafts.id = campaigns.campaign_draft_id').where(campaigns: {campaign_draft_id: nil})
  end
  
  def self.visibility_select
    VISIBILITIES.map{|value|
      [I18n.t!("campaign_drafts.publish_form.#{value}_visibility"), value]
    }
  end
  
  def self.minimum_active_hours
    1
  end
  
  def starts_at_criterion
    starts_immediately ? created_at : starts_at
  end
  
  def do_generate_invite_link
    if generate_invite_link && changes[:generate_invite_link]
      self.invite_token = SecureRandom.hex(6)
    end
  end
  
  def maybe_discard_starts_at
    if self.starts_immediately
      self.starts_at = nil
    end
  end
  
  def valid_date_fields
    if starts_at_criterion && ends_at
      if starts_at_criterion > ends_at
        errors[:starts_at] << I18n.t!('campaigns.errors.starts_at.ends_at')
      end
      if ends_at.to_i - starts_at_criterion.to_i < self.class.minimum_active_hours.hours
        unless Rails.env.production? && DeveloperMachine.running_in_developer_machine? # sometimes one runs production in a developer machine.
          errors[:ends_at] << I18n.t!('campaigns.errors.ends_at.starts_at', hours: self.class.minimum_active_hours)
        end
      end
    end
    if (dev_or_test? ? !skip_past_date_validations : true)
      if starts_at && starts_at.to_i - DateTime.current.to_i < -60
        errors[:starts_at] << I18n.t!('past_date')
      end
      if ends_at && ends_at.to_i - DateTime.current.to_i < -60
        errors[:ends_at] << I18n.t!('past_date')
      end
    end
  end
  
  def minimum_pledge_not_greater_than_goal
    if minimum_pledge_cents && goal_cents
      if (goal_cents.to_f / minimum_pledge_cents.to_f) < GOAL_TO_MINIMUM_PLEDGE_FACTOR.to_f
        errors[:minimum_pledge_cents] << I18n.t!('campaigns.errors.minimum_pledge_cents.goal_cents', n: GOAL_TO_MINIMUM_PLEDGE_FACTOR)
      end
    end
  end
  
  def minimum_pledge_according_to_venue
    if minimum_pledge_cents && goal_cents && venue
      if minimum_pledge_cents < estimated_minimum_pledge_cents
        errors[:minimum_pledge_cents] << I18n.t!("campaigns.errors.minimum_pledge_cents.venue", value: estimated_minimum_pledge.format)
      end
    end
  end
  
  def estimated_minimum_pledge_cents
    if venue
      goal_cents / venue.capacity
    else
      nil
    end
  end
  
  def create_campaign
    change = changes[:published_at]
    if change && change[0].nil? && change[1].present?
      self.campaign ||= Campaign.new(campaign_draft: self)
    end
  end
  
end
