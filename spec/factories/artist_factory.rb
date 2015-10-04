FG.define do
  
  factory :artist do
    
    name "Dixon"
    website "innervisions.com"
    email 'dixon@innervisions.com'
    telephone "609929302"
    
    trait :with_events do
      
      after(:build) do |rec, eva|
        
        rec.events << FactoryGirl.build(:event, artists: [rec])
        
      end
      
    end
    
  end
  
end