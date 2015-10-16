FG.define do
  
  factory :campaign do
    
    association :event_promoter
    name "Fund my party"
    description "I was thinking of throwing the perfect party, in a great open-air venue, at daytime, and with some of the latest and greatest DJs out there."
    starts_at { DateTime.now.beginning_of_day }
    ends_at { 30.days.from_now }
    goal_cents { Random.rand(Campaign::MAXIMUM_GOAL_AMOUNT - Campaign::MINIMUM_GOAL_AMOUNT).to_i + Campaign::MINIMUM_GOAL_AMOUNT}
    
  end
  
end