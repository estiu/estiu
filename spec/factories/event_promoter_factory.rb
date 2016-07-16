FG.define do
  
  factory :event_promoter do
    
    name "Event Promoter #{SecureRandom.hex(4)}"
    
    website {"#{SecureRandom.hex(12)}.com"}
    
    after(:build) do |rec, eva|
      
      unless rec.user
        rec.user = FG.build :user, event_promoter: rec, roles: [:event_promoter]
      end

      rec.email = rec.user.email

      if rec.contacts.size.zero?
        
        rec.contacts << FG.build(:contact)
        
      end
      
    end
    
  end
  
end