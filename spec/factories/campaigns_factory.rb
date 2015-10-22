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
      rec.minimum_pledge_cents = (rec.goal_cents / rec.venue.capacity).ceil
    end
    
    trait :pledged do
      
      goal_cents {
        max = Campaign::MINIMUM_GOAL_AMOUNT + 100_00
        Random.rand(Campaign::MINIMUM_GOAL_AMOUNT).to_i + Campaign::MINIMUM_GOAL_AMOUNT
      }
      
      after(:create) do |rec, eva|
        
        fail unless rec.active?
        
        until rec.fulfilled?
          
          rec.pledges << FG.create(:pledge, campaign: rec)
          
        end
      
      end
      
    end
    
  end
  
end