FG.define do
  
  factory :resident_advisor_path do
    
    value { "dj/#{SecureRandom.hex}" }
    
    after(:build) do |rec, eva|
      
      unless rec.artist_name
        rec.artist_name = rec.value
      end
      
    end
    
  end
  
end