class Attendee < ActiveRecord::Base
  
  has_and_belongs_to_many :events, join_table: :tickets
  has_and_belongs_to_many :campaigns, join_table: :pledges
  has_many :tickets
  has_many :pledges
  has_one :user
  
  %i(first_name last_name user).each do |attr|
    validates attr, presence: true
  end
  
  def pledged? campaign
    campaign.pledges.pluck(:attendee_id).include? self.id
  end
  
  def pledged_for campaign
    (campaign.pledges.where(attendee: self).sum(:amount_cents) / 100.0).to_money
  end
  
end
