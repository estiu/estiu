FG.define do
  
  factory :attendee do
    
    first_name "Foo"
    last_name "Bar"
    email "foo@bar.com"
    
    trait :with_tickets do
      
      after(:build) do |rec, eva|
        
        rec.tickets << FactoryGirl.build(:ticket, attendee: rec, event: FG.build(:event))
        
      end
      
    end
    
  end
  
end