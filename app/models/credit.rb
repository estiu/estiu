class Credit < ActiveRecord::Base
  
  belongs_to :attendee
  belongs_to :pledge
  belongs_to :refunded_pledge, class_name: Pledge
  
  default_scope { where charged: false }
  
  after_commit :notify_attendee, on: :create
  
  monetize :amount_cents, subunit_numericality: {
    greater_than: 0
  }
  
  validates :charged, inclusion: [true, false]
  
  validates :attendee, presence: true
  validates :pledge, presence: true, unless: :refunded_pledge
  validates :refunded_pledge, presence: true, unless: :pledge
  
  def notify_attendee
    CreditCreationJob.perform_later(self.id)
  end
  
  def to_s
    I18n.t("credits.to_s", amount: amount.format, referrer: pledge.attendee.first_name)
  end
  
end
