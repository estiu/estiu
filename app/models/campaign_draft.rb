class CampaignDraft < ActiveRecord::Base
  
  extend Approvable
  
  belongs_to :venue
  belongs_to :event_promoter
  has_one :campaign

  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  DATE_ATTRS = %i(starts_at ends_at)
  CREATE_ATTRS_STEP_1 = %i(name description venue_id proposed_goal_cents minimum_pledge_cents cost_justification)
  CREATE_ATTRS_STEP_2 = DATE_ATTRS + %i(starts_immediately time_zone visibility generate_invite_link estimated_event_date estimated_event_hour estimated_event_minutes)
  FORWARD_METHODS = %i(
    starts_at_criterion
    skip_past_date_validations
    venue
    event_promoter
    proposed_goal
    goal
    goal_cents
    invite_token
    minimum_pledge
  )
  PUBLIC_VISIBILITY = 'public'
  APP_VISIBILITY = 'app'
  INVITE_VISIBILITY = 'invite'
  VISIBILITIES = [APP_VISIBILITY, INVITE_VISIBILITY, PUBLIC_VISIBILITY]
  GOAL_TO_MINIMUM_PLEDGE_FACTOR = 10 # goal must be at least 10 times higher than the minimum pledge, so at least 10 people can attend.
  FORMAT_OPTS = {no_cents_if_whole: false}.freeze
  
  extend ResettableDates
  
  monetize :proposed_goal_cents, subunit_numericality: {
    greater_than_or_equal_to: MINIMUM_GOAL_AMOUNT,
    less_than: MAXIMUM_GOAL_AMOUNT,
    message: I18n.t!("money_range", min: Money.new(MINIMUM_GOAL_AMOUNT).format, max: Money.new(MAXIMUM_GOAL_AMOUNT).format)
  }
  
  monetize :minimum_pledge_cents, subunit_numericality: {
    more_than: Pledge::STRIPE_MINIMUM_PAYMENT,
    less_than: Pledge::MAXIMUM_PLEDGE_AMOUNT
  }
  
  monetize :estimated_minimum_pledge_cents, allow_nil: true
  monetize :goal_cents, allow_nil: true
  monetize :commissions_cents, allow_nil: true
  monetize :taxes_cents, allow_nil: true
  
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
  validates :published_at, inclusion: [nil], if: ->(rec){ production_or_staging? ? !rec.id : false }
  validates :submitted_at, inclusion: [nil], if: ->(rec){ production_or_staging? ? !rec.id : false }
  validates :goal_cents, inclusion: [nil], unless: :submitted_at
  
  begin # validations enclosed in this black depend on :published_at
    validates :goal_cents, presence: true, if: :published_at
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
    validate :estimated_event_datetime_present, if: :published_at
  end

  validate :valid_date_fields, if: :being_published?
  validate :minimum_pledge_according_to_venue
  validate :minimum_pledge_not_greater_than_goal

  before_validation :generate_goal_cents, if: :needs_goal_cents_generation?
  before_validation :do_generate_invite_link
  before_validation :maybe_discard_starts_at

  attr_accessor :proposed_goal_cents_facade
  attr_accessor :commissions_cents
  attr_accessor :taxes_cents
  
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
  
  def needs_goal_cents_generation?
    (submitted_at && !published_at) || changes[:published_at].present?
  end
  
  def being_published?
    (approved_at && changes[:approved_at].blank? && !published_at) || changes[:published_at].present?
  end
  
  def starts_at_criterion
    starts_immediately ? created_at : starts_at
  end
  
  def estimated_event_datetime_conditions
    [time_zone, estimated_event_date, estimated_event_hour, estimated_event_minutes].all? &:present?
  end
  
  def estimated_event_datetime
    if estimated_event_datetime_conditions
      if tz = ActiveSupport::TimeZone.all.detect{|t| t.tzinfo.name == time_zone }
        tz.local estimated_event_date.year, estimated_event_date.month, estimated_event_date.day, estimated_event_hour, estimated_event_minutes
      end
    end
  end
  
  def generate_goal_cents
    self.commissions_cents = Commissions.calculate_for(self)
    self.goal_cents = self.proposed_goal_cents + self.commissions_cents
    self.taxes_cents = Taxes.calculate_for(self)
    self.goal_cents += self.taxes_cents
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
  
  def estimated_event_datetime_present
    if estimated_event_datetime_conditions && !estimated_event_datetime
      self.errors[:estimated_event_date] << I18n.t!('campaigns.errors.estimated_event_date.estimated_event_datetime')
    end
  end
  
  def valid_date_fields
    if starts_at_criterion && ends_at
      if starts_at_criterion > ends_at
        errors[:starts_at] << I18n.t!('campaigns.errors.starts_at.ends_at')
      end
      if ends_at.to_i - starts_at_criterion.to_i < self.class.minimum_active_hours.hours
        unless production_or_staging? && DeveloperMachine.running_in_developer_machine? # sometimes one runs production in a developer machine.
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
    if estimated_event_datetime && ends_at && (estimated_event_datetime < ends_at)
      errors[:estimated_event_date] << I18n.t!('campaigns.errors.estimated_event_date.ends_at')
    end
  end
  
  def minimum_pledge_not_greater_than_goal
    if minimum_pledge_cents && proposed_goal_cents
      if (proposed_goal_cents.to_f / minimum_pledge_cents.to_f) < GOAL_TO_MINIMUM_PLEDGE_FACTOR.to_f
        errors[:minimum_pledge_cents] << I18n.t!('campaigns.errors.minimum_pledge_cents.goal_cents', n: GOAL_TO_MINIMUM_PLEDGE_FACTOR)
      end
    end
  end
  
  def minimum_pledge_according_to_venue
    
    had_goal_cents = goal_cents.present?
    
    if proposed_goal_cents && !goal_cents
      generate_goal_cents
    end
    
    if minimum_pledge_cents && goal_cents && venue
      if minimum_pledge_cents < estimated_minimum_pledge_cents
        errors[:minimum_pledge_cents] << I18n.t!("campaigns.errors.minimum_pledge_cents.venue", value: estimated_minimum_pledge.format)
      end
    end
    
    (self.goal_cents = nil) unless had_goal_cents
    
  end
  
  def estimated_minimum_pledge_cents
    if goal_cents && venue
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
  
  def present_calculations
    
    generate_goal_cents
    total = goal
    
    formatted_total = total.format(FORMAT_OPTS.dup)
    formatted_total_no_symbol = goal_cents.zero? ? nil : total.format(FORMAT_OPTS.dup.merge(symbol: false))
    
    explanation = if goal_cents.zero?
      goal.format(FORMAT_OPTS.dup)
    else
      base_formatted_no_symbol = proposed_goal.format(FORMAT_OPTS.dup.merge(symbol: false))
      commissions_formatted_no_symbol = commissions.format(FORMAT_OPTS.dup.merge(symbol: false))
      taxes_formatted_no_symbol = taxes.format(FORMAT_OPTS.dup.merge(symbol: false))
      "#{base_formatted_no_symbol} + #{commissions_formatted_no_symbol} + #{taxes_formatted_no_symbol} = #{formatted_total}"
    end
    
    {
      explanation: explanation,
      formatted_total: formatted_total,
      formatted_total_no_symbol: formatted_total_no_symbol,
      cents_total: total.fractional
    }
    
  end
  
end
