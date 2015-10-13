FG.define do
  
  factory :attendee do
    
    first_name { SecureRandom.hex(12) }
    last_name { SecureRandom.hex(12) }
    
    trait :with_tickets do
      
      after(:build) do |rec, eva|
        
        rec.tickets << FactoryGirl.build(:ticket, attendee: rec, event: FG.build(:event))
        
      end
      
    end
    
  end
  
end