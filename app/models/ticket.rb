class Ticket < ActiveRecord::Base
  
  belongs_to :attendee
  belongs_to :event
  
  validates :attendee, presence: true
  validates :event, presence: true
  validates :attendee_id, uniqueness: {scope: :event_id}
  
  after_commit :notify_attendee, on: :create
  
  def notify_attendee
    Events::Approval::TicketNotificationJob.perform_later id
  end
  
end
