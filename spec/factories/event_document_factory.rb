FG.define do
  
  factory :event_document do
    
    association :event
    
    filename { SecureRandom.hex }
    visible_name { SecureRandom.hex }
    key { SecureRandom.hex }
    
  end
  
end