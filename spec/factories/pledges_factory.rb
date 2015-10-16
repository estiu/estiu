FG.define do
  
  factory :pledge do
    
    association :attendee
    association :campaign
    amount_cents 50_00
      
  end
  
end