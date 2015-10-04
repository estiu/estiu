FG.define do
  
  factory :campaign do
    
    association :event_promoter
    name "Fund my party"
    description "Gonna be awesmoe"
    starts_at { Date.tomorrow }
    ends_at { 30.days.from_now }
    goal_cents { Random.rand(Campaign::MAXIMUM_GOAL_AMOUNT - Campaign::MINIMUM_GOAL_AMOUNT).to_i + Campaign::MINIMUM_GOAL_AMOUNT}
    
  end
  
end