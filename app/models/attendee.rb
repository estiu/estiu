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
    campaign.pledges.find_by(attendee_id: self.id)
  end
  
  def pledged? campaign
    pledge_for(campaign).present?
  end
  
end
