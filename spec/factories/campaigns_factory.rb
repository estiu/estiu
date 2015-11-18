FG.define do
  
  factory :campaign do
    
    association :event_promoter
    association :venue
    name "Fund my party"
    description "I was thinking of throwing the perfect party, in a great open-air venue, at daytime, and with some of the latest and greatest DJs out there."
    starts_at { DateTime.now.beginning_of_day }
    ends_at { 30.days.from_now }
    goal_cents { Random.rand(Campaign::MAXIMUM_GOAL_AMOUNT - Campaign::MINIMUM_GOAL_AMOUNT).to_i + Campaign::MINIMUM_GOAL_AMOUNT}
    skip_past_date_validations true
    
    after(:build) do |rec, eva|
      rec.minimum_pledge_cents = [(rec.goal_cents / rec.venue.capacity).ceil, Pledge::STRIPE_MINIMUM_PAYMENT].max
    end
    
    trait :fulfilled do
      
      after(:create) do |rec, eva|
        
        fail if rec.fulfilled?
        
        pledge_count = 5
        amount_cents = (rec.goal_cents.to_f / pledge_count.to_f).floor
        
        pledge_count.times {
          rec.pledges << FG.create(:pledge, campaign: rec, amount_cents: amount_cents)
        }
      
      end
      
    end
    
    trait :almost_fulfilled do
      
      after(:create) do |rec, eva|
        
        fail if rec.fulfilled?
        pledge_count = 5
        amount_cents = ((rec.goal_cents - rec.minimum_pledge_cents - 1).to_f / pledge_count.to_f).floor
        
        pledge_count.times {
          rec.pledges << FG.create(:pledge, campaign: rec, amount_cents: amount_cents)
        }
        
        fail if rec.fulfilled?
        
      end
      
    end
    
    trait :with_one_pledge do
      
      after(:create) do |rec, eva|
        
        fail if rec.fulfilled?
        pledge_count = 5
        amount_cents = ((rec.goal_cents - rec.minimum_pledge_cents - 1).to_f / pledge_count.to_f).floor
        
        1.times {
          rec.pledges << FG.create(:pledge, campaign: rec, amount_cents: amount_cents)
        }
        
        fail if rec.fulfilled?
        
      end
      
    end
    
    trait :with_referred_attendee do
      
      transient do
        referred_attendee nil
        referrers_count 2
      end
      
      after(:create) do |rec, eva|
        
        fail unless rec.active?
        FG.create(:pledge, campaign: rec, amount_cents: rec.minimum_pledge_cents, attendee: eva.referred_attendee)
        eva.referrers_count.times {
          pledge = FG.create(:pledge, campaign: rec, amount_cents: rec.minimum_pledge_cents, referral_email: eva.referred_attendee.user.email, stripe_charge_id: nil)
          pledge.update_attributes!(stripe_charge_id: SecureRandom.hex)
        }
        fail if rec.fulfilled?
        
      end
      
    end
    
  end
  
end