FG.define do
  
  factory :artist_promoter do
    
    name "The Artist promoter"
    email "artist@promoter.com"
    website "artistpromoter.com"
    
    after(:build) do |rec, eva|
      
      unless rec.user
        rec.user = FG.build :user, artist_promoter: rec, roles: [:artist_promoter]
      end

      if rec.contacts.size.zero?
        
        rec.contacts << FG.build(:contact)
        
      end
      
    end
    
  end
  
end