FG.define do
  
  factory :user do
    
    email { "#{SecureRandom.hex 6}@#{SecureRandom.hex 6}.com" }
    password { SecureRandom.hex }
    role :attendee
    
    Roles.all.each do |_role|
      trait _role do
        role _role
      end
    end
    
  end
  
end