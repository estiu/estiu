FG.define do
  
  factory :user do
    
    email { "#{SecureRandom.hex 6}@#{SecureRandom.hex 6}.com" }
    password { SecureRandom.hex }
    
    default_role = :attendee
    role default_role
    
    after(:build) do |rec, eva|
      rec.send("#{rec.role}=", FG.build(rec.role.to_sym))
    end
    
    Roles.all.each do |_role|
      trait "#{_role}_role".to_sym do
        role _role
        association _role
        after(:build) do |rec, eva|
          unless _role == default_role
            rec.send("#{default_role}_id=", nil)
          end
        end
      end
    end
    
  end
  
end