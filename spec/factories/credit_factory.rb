FG.define do
  
  factory :credit do
    
    association :attendee
    
    amount_cents { Pledge::DISCOUNT_PER_REFERRAL }
    charged false
    
    trait :referral do
      association :referral_pledge, factory: :pledge
    end
    
    trait :refund do
      association :refunded_pledge, factory: :pledge
    end
    
    after(:build) do |rec, eva|
      unless rec.referral_pledge || rec.refunded_pledge
        rec.referral_pledge = FG.build :pledge
      end
    end
    
  end
  
end