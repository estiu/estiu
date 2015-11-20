FG.define do
  
  factory :artist do
    
    name { %w(Dixon Darius Ada Aeroplane Clavis Daso Extrawelt Thor Argy Percussions Dauwd Isolée Davi Coma SB).sample }
    website "innervisions.com"
    email 'dixon@innervisions.com'
    telephone "609929302"
    association :ra_artist
    
    trait :with_events do
      
      after(:build) do |rec, eva|
      
        rec.events << FactoryGirl.build(:event, artists: [rec])
        
      end
      
    end
    
  end
  
end