class EventPromoter < ActiveRecord::Base
  
  has_many :campaigns
  has_many :contacts, as: :contactable
  has_one :user
  
  %i(name email website).each do |attr|
    validates attr, presence: true
  end
  
end
