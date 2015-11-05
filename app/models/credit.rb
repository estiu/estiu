class Credit < ActiveRecord::Base
  
  belongs_to :attendee
  belongs_to :pledge
  
  default_scope { where charged: false }
  
  after_commit :notify_attendee
  
  monetize :amount_cents, subunit_numericality: {
    greater_than: 0
  }
  
  validates :charged, inclusion: [true, false]
  
  validates_presence_of :attendee
  validates_presence_of :attendee_id
  validates_presence_of :pledge
  validates_presence_of :pledge_id
  
  def notify_attendee
    
  end
  
  def to_s
    I18n.t("credits.to_s", amount: amount.format, referrer: pledge.attendee.first_name)
  end
  
end
