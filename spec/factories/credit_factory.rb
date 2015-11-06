FG.define do
  
  factory :credit do
    
    association :attendee
    association :pledge
    amount_cents { Pledge::DISCOUNT_PER_REFERRAL }
    charged false
    
  end
  
end