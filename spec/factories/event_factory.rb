FG.define do
  
  factory :event do
    
    name "Best party ever"
    starts_at {Date.tomorrow}
    duration {6.hours}
    association :campaign
    association :venue
    
    after(:build) do |rec, eva|
      
      if rec.artists.size.zero?
        
        rec.artists << FG.build(:artist)
        
      end
      
    end
    
  end
  
end