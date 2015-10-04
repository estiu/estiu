FG.define do
  
  factory :ticket do
    
    association :attendee
    association :event
      
  end
  
end