FG.define do
  
  factory :ra_artist do
    
    artist_path { "dj/#{SecureRandom.hex}" }
    
    after(:build) do |rec, eva|
      
      unless rec.artist_name
        rec.artist_name = rec.artist_path
      end
      
    end
    
  end
  
end