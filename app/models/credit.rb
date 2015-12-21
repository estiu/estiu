class Credit < ActiveRecord::Base
  
  belongs_to :attendee
  belongs_to :referral_pledge, class_name: Pledge
  belongs_to :refunded_pledge, class_name: Pledge
  
  default_scope { where charged: false }
  
  after_commit :notify_attendee, on: :create
  
  monetize :amount_cents, subunit_numericality: {
    greater_than: 0
  }
  
  validates :charged, inclusion: [true, false]
  
  validates :attendee, presence: true
  validates :referral_pledge, presence: true, unless: :refunded_pledge
  validates :refunded_pledge, presence: true, unless: :referral_pledge
  validates :referral_pledge_id, inclusion: [nil], if: :refunded_pledge
  validates :refunded_pledge_id, inclusion: [nil], if: :referral_pledge
  
  def notify_attendee
    CreditCreationJob.perform_later(self.id)
  end
  
  def to_s
    if referral_pledge
      I18n.t("credits.to_s.referral_pledge", amount: amount.format, referrer: referral_pledge.attendee.first_name)
    elsif refunded_pledge
      I18n.t("credits.to_s.refunded_pledge", amount: amount.format)
    else
      raise
    end
  end
  
end
