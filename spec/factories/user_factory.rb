FG.define do
  
  factory :user do
    
    email { "#{SecureRandom.hex(16)}@mailinator.com" } # mail can be actually checked at mailinator.com.
    password { SecureRandom.hex }
    confirmed_at { DateTime.now }
    
    default_role = 'attendee'
    roles [default_role]
    
    after(:build) do |rec, eva|
      rec.roles.each do |role|
        if Roles.with_associated_models.include? role
          rec.send("#{role}=", FG.build(role.to_sym, user: rec)) unless rec.send(role)
        end
      end
    end
    
    Roles.all.each do |_role|
      trait "#{_role}_role".to_sym do
        roles [_role]
      end
    end
    
  end
  
end