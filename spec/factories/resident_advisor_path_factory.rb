FG.define do
  
  factory :resident_advisor_path do
    
    value { "dj/#{SecureRandom.hex}" }
    
  end
  
end