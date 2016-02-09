class Campaign < ActiveRecord::Base
  
  belongs_to :campaign_draft
  
  has_many :pledges
  has_one :event
  
  validates :campaign_draft, presence: true
  validate :fulfilled_at_truthful
  validate :unfulfilled_at_truthful
  
  attr_accessor :force_job_running
  attr_accessor :passed_invite_token
  
  after_commit :schedule_unfulfillment_check, on: :create
  after_commit :unschedule_unfulfillment_check, on: :destroy
  after_commit :send_fulfillment_emails, on: :update
  after_commit :check_unfulfilled_at, on: :update
  
  monetize :pledged_cents
  
  (CampaignDraft::CREATE_ATTRS_STEP_1 + CampaignDraft::CREATE_ATTRS_STEP_2 + %i(starts_at_criterion skip_past_date_validations venue event_promoter)).each do |attr|
    delegate attr, to: :campaign_draft
  end
  
  def attendees # manually define relationship so the Pledge default_scope is taken into account
    Attendee.joins(:pledges).where(pledges: {id: pledges.pluck(:id)})
  end
  
  def to_s
    name
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
  
  def percent_pledged
    if fulfilled?
      100 # no decimal places
    else
      (pledged_cents.to_f / goal_cents.to_f * 100).round 2
    end
  end
  
  def pledged_cents
    Pledge.uncached {
      pledges.sum(:originally_pledged_cents)
    }
  end
  
  def active_time?
    Rails.env.test? && skip_past_date_validations ? true : (starts_at_criterion..ends_at).cover?(DateTime.current)
  end
  
  def active?
    active_time? && !fulfilled? && !unfulfilled_at
  end
  
  def fulfilled?
    (!!fulfilled_at) || (goal_cents - pledged_cents < minimum_pledge_cents)
  end
  
  def closed?
    fulfilled? || !active?
  end
  
  def not_open_yet?
    now = DateTime.current
    (now..starts_at_criterion).cover?(now)
  end
  
  def maximum_pledge_cents
    Pledge::MAXIMUM_PLEDGE_AMOUNT
  end
  
  def remaining_amount_cents
    v = goal_cents - pledged_cents
    v < 0 ? 0 : v # should never be < 0, but better safe than sorry
  end
  
  def user_email_pledged? email
    attendees.joins(:user).where(users: {email: email}).any?
  end
  
  def maybe_mark_as_fulfilled

    # this method is meant to be called within a ActiveRecord::Base.transaction. failing to do will result in unsafe operations.
    # wrapping the method body in a transaction would also be wrong since AR nested transactions are fake/deceiving.
    fail if ActiveRecord::Base.connection.open_transactions.zero?

    if fulfilled? && !fulfilled_at
      self.fulfilled_at = DateTime.now
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
