FG.define do
  
  factory :event_promoter do
    
    name "TheEventPromoter"
    
    after(:build) do |rec, eva|
      
      if rec.contacts.size.zero?
        
        rec.contacts << FG.build(:contact)
        
      end
      
    end
    
  end
  
end