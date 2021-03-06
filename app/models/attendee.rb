class Attendee < ActiveRecord::Base
  
  has_and_belongs_to_many :events, join_table: :tickets
  has_and_belongs_to_many :campaigns, join_table: :pledges
  has_many :tickets
  has_many :pledges
  has_many :credits
  has_one :user
  
  %i(first_name last_name user).each do |attr|
    validates attr, presence: true
  end
  
  def pledge_for campaign
    # be careful when caching - must be done per campaign.id
    campaign.pledges.find_by(attendee_id: self.id)
  end
  
  def pledged? campaign
    pledge_for(campaign).present?
  end
  
  def refundable_pledge_for campaign
    pledge = pledge_for campaign
    return false unless pledge
    if pledge.refunded?
      false
    else
      pledge
    end
  end
  
  def ticket_for event
    # be careful when caching - must be done per event.id
    Ticket.find_by(attendee: self, event: event)
  end
  
end
