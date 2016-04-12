class EventPromoter < ActiveRecord::Base
  
  has_many :campaign_drafts
  has_many :campaigns, through: :campaign_drafts
  has_many :contacts, as: :contactable
  has_one :user
  
  %i(name email website user).each do |attr|
    validates attr, presence: true
  end
  
  def to_s
    name
  end
  
end
