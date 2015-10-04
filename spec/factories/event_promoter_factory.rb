FG.define do
  
  factory :event_promoter do
    
    name "TheEventPromoter"
    email "event@promoter.com"
    website "eventpromoter.com"
    
    after(:build) do |rec, eva|
      
      if rec.contacts.size.zero?
        
        rec.contacts << FG.build(:contact)
        
      end
      
    end
    
  end
  
end