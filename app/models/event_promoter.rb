class EventPromoter < ActiveRecord::Base
  
  has_many :campaigns
  
  has_many :contacts, as: :contactable
  
end
