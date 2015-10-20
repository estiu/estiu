FG.define do
  
  factory :user do
    
    email { "#{SecureRandom.hex 6}@#{SecureRandom.hex 6}.com" }
    password { SecureRandom.hex }
    confirmed_at { DateTime.now }
    
    default_role = 'attendee'
    roles [default_role]
    
    after(:build) do |rec, eva|
      rec.roles.each do |role|
        if Roles.with_associated_models.include? role
          rec.send("#{role}=", FG.build(role.to_sym)) unless rec.send(role)
        end
      end
    end
    
    Roles.all.each do |_role|
      trait "#{_role}_role".to_sym do
        roles [_role]
        if Roles.with_associated_models.include? _role
          association _role.to_sym
          after(:build) do |rec, eva|
            unless _role == default_role
              rec.send("#{default_role}_id=", nil)
            end
          end
        end
      end
    end
    
  end
  
end