class Campaign < ActiveRecord::Base
  
  MINIMUM_GOAL_AMOUNT = 100_00
  MAXIMUM_GOAL_AMOUNT = 15_000_00
  DATE_ATTRS = %i(starts_at ends_at)
  BASIC_ATTRS = %i(name venue_id) + DATE_ATTRS
  CREATE_ATTRS = BASIC_ATTRS + [:description, :goal_cents, :minimum_pledge_cents, :generate_invite_link, :visibility]
  PUBLIC_VISIBILITY = 'public'
  APP_VISIBILITY = 'app'
  INVITE_VISIBILITY = 'invite'
  VISIBILITIES = [APP_VISIBILITY, INVITE_VISIBILITY, PUBLIC_VISIBILITY]
  
  extend ResettableDates
  
  belongs_to :event_promoter
  belongs_to :venue
  has_and_belongs_to_many :attendees, join_table: :pledges
  has_many :pledges
  has_one :event
  
  monetize :goal_cents, subunit_numericality: {
    greater_than_or_equal_to: MINIMUM_GOAL_AMOUNT,
    less_than: MAXIMUM_GOAL_AMOUNT,
    message: I18n.t("money_range", min: Money.new(MINIMUM_GOAL_AMOUNT).format, max: Money.new(MAXIMUM_GOAL_AMOUNT).format)
  }
  
  monetize :minimum_pledge_cents, subunit_numericality: {
    more_than: Pledge::STRIPE_MINIMUM_PAYMENT,
    less_than: Pledge::MAXIMUM_PLEDGE_AMOUNT
  }
  
  monetize :pledged_cents
  monetize :estimated_minimum_pledge_cents
  
  BASIC_ATTRS.each do |attr|
    validates attr, presence: true
  end
  
  validates :invite_token, presence: true, if: :generate_invite_link
  validates :invite_token, inclusion: [nil], unless: :generate_invite_link
  validates :visibility, inclusion: {in: VISIBILITIES, message: I18n.t('errors.inclusion')}
  validates :generate_invite_link, inclusion: {in: [true, false], message: I18n.t('errors.inclusion')}
  validates :generate_invite_link,
    inclusion: {in: [true], message: I18n.t('campaigns.errors.generate_invite_link')},
    if: ->(record){
      record.generate_invite_link == false && # check false, not nil
      record.visibility == INVITE_VISIBILITY
    }
  validates :generate_invite_link,
    inclusion: {in: [false], message: I18n.t('campaigns.errors.generate_invite_link_false')},
    if: ->(record){
      record.generate_invite_link &&
      record.visibility == PUBLIC_VISIBILITY
    }
  validates :description, presence: true, length: {minimum: 140, maximum: 1000}
  
  validate :valid_date_fields, on: :create
  validate :minimum_pledge_according_to_venue, on: :create
  validate :fulfilled_at_truthful
  validate :unfulfilled_at_truthful
  
  attr_accessor :goal_cents_facade
  attr_accessor :force_job_running
  attr_accessor :passed_invite_token
  
  before_validation :do_generate_invite_link
  
  after_commit :schedule_unfulfillment_check, on: :create
  after_commit :unschedule_unfulfillment_check, on: :destroy
  after_commit :send_fulfillment_emails, on: :update
  after_commit :check_unfulfilled_at, on: :update
  
  def self.minimum_active_hours
    1
  end
  
  def self.visible_for_event_promoter event_promoter
    where(campaigns: {event_promoter_id: event_promoter.id})
  end
  
  def self.visible_for_attendee attendee
    joins(:pledges).where(pledges: {attendee_id: attendee.id})
  end
  
  def self.without_event
    joins('left outer join events on campaigns.id = events.campaign_id').where(events: {campaign_id: nil})
  end
  
  def self.fulfilled
    where.not(fulfilled_at: nil)
  end
  
  def self.visibility_select
    VISIBILITIES.map{|value|
      [I18n.t("campaigns.form.#{value}_visibility"), value]
    }
  end
  
  def percent_pledged
    if fulfilled?
      100 # no decimal places
    else
      (pledged_cents.to_f / goal_cents.to_f * 100).round 2
    end
  end
  
  def pledged_cents
    Pledge.uncached {
      pledges.sum(:amount_cents)
    }
  end
  
  def active?
    active_time = Rails.env.test? && skip_past_date_validations ? true : (starts_at..ends_at).cover?(Time.zone.now)
    active_time && !fulfilled?
  end
  
  def fulfilled?
    goal_cents - pledged_cents < minimum_pledge_cents
  end
  
  def closed?
    fulfilled? || !active?
  end
  
  def maximum_pledge_cents
    Pledge::MAXIMUM_PLEDGE_AMOUNT
  end
  
  def remaining_amount_cents
    v = goal_cents - pledged_cents
    v < 0 ? 0 : v # should never be < 0, but better safe than sorry
  end
  
  def user_email_pledged? email
    Campaign.joins(attendees: :user).where.not(pledges: {stripe_charge_id: nil}).where(users: {email: email}, campaigns: {id: id}).any?
  end
  
  def valid_date_fields
    if starts_at && ends_at
      if starts_at > ends_at
        errors[:starts_at] << I18n.t('campaigns.errors.starts_at.ends_at')
      end
      if ends_at.to_i - starts_at.to_i < self.class.minimum_active_hours.hours
        unless Rails.env.production? && DeveloperMachine.running_in_developer_machine? # sometimes one runs production in a developer machine.
          errors[:ends_at] << I18n.t('campaigns.errors.ends_at.starts_at', hours: self.class.minimum_active_hours)
        end
      end
    end
    if (dev_or_test? ? !skip_past_date_validations : true)
      if starts_at && starts_at.to_i - Time.zone.now.to_i < -60
        errors[:starts_at] << I18n.t('past_date')
      end
      if ends_at && ends_at.to_i - Time.zone.now.to_i < -60
        errors[:ends_at] << I18n.t('past_date')
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
  
  def minimum_pledge_according_to_venue
    if minimum_pledge_cents && goal_cents && venue
      if minimum_pledge_cents < estimated_minimum_pledge_cents
        errors[:minimum_pledge_cents] << I18n.t("campaigns.errors.minimum_pledge_cents.venue", value: estimated_minimum_pledge.format)
      end
    end
  end
  
  def maybe_mark_as_fulfilled

    # this method is meant to be called within a ActiveRecord::Base.transaction. failing to do will result in unsafe operations.
    # wrapping the method definition in a transaction would also be wrong since AR nested transactions are fake/deceiving.
    fail if ActiveRecord::Base.connection.open_transactions.zero?

    if fulfilled? && !fulfilled_at
      self.fulfilled_at = Time.now
      self.save
    end
    
  end
  
  def send_fulfillment_emails
    change = previous_changes[:fulfilled_at]
    if change && change[0].nil? && change[1].present?
      CampaignFulfillmentJob.perform_later(self.id)
    end
  end
  
  def check_unfulfilled_at
    change = previous_changes[:unfulfilled_at]
    if change && change[0].nil? && change[1].present?
      CampaignUnfulfillmentJob.perform_later(self.id)
    end
  end
  
  def fulfilled_at_truthful
    if fulfilled_at && !fulfilled?
      errors[:fulfilled_at] << "Cannot be set if the campaign isn't actually fulfilled."
    end
  end
  
  
  def unfulfilled_at_truthful
    if unfulfilled_at && fulfilled?
      errors[:unfulfilled_at] << "Cannot be set if the campaign is actually fulfilled."
    end
  end
  
  def schedule_unfulfillment_check
    CampaignUnfulfillmentCheckJob.perform_later(self.id, self.force_job_running)
  end
  
  def unschedule_unfulfillment_check
    CampaignUnfulfillmentUnscheduleJob.perform_later(self.id)
  end
  
  def do_generate_invite_link
    if generate_invite_link && changes[:generate_invite_link]
      self.invite_token = SecureRandom.hex(6)
    end
  end
  
  def shareable_url current_user, include_referral_email=false
    opts = {id: id}
    opts.merge!({referral_email: current_user.email}) if include_referral_email
    if invite_token
      Rails.application.routes.url_helpers.show_with_invite_token_campaign_url(opts.merge(invite_token: invite_token))
    else
      Rails.application.routes.url_helpers.campaign_url(opts)
    end
  end
  
end
