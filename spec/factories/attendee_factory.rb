FG.define do
  
  factory :attendee do
    
    first_name { SecureRandom.hex 7 }
    last_name { SecureRandom.hex 7 }
    
    after(:build) do |rec, eva|
      
      unless rec.user
        rec.user = FG.build :user, attendee: rec, roles: [:attendee]
      end
      
    end
    
    trait :with_tickets do
      
      after(:build) do |rec, eva|
        
        rec.tickets << FactoryGirl.build(:ticket, attendee: rec, event: FG.build(:event))
        
      end
      
    end
    
  end
  
end