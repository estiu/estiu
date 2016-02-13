FG.define do
  
  factory :campaign_draft do
    
    association :event_promoter
    association :venue
    name "Fund my party"
    description "I was thinking of throwing the perfect party, in a great open-air venue, at daytime, and with some of the latest and greatest DJs out there."
    goal_cents { Random.rand(CampaignDraft::MAXIMUM_GOAL_AMOUNT - CampaignDraft::MINIMUM_GOAL_AMOUNT).to_i + CampaignDraft::MINIMUM_GOAL_AMOUNT}
    skip_past_date_validations true
    
    after(:build) do |rec, eva|
      rec.minimum_pledge_cents = [(rec.goal_cents / rec.venue.capacity).ceil, Pledge::STRIPE_MINIMUM_PAYMENT].max
    end
    
    trait :submitted do
      submitted_at { DateTime.now }
    end
    
    trait :approved do
      submitted
      approved_at { DateTime.now }
    end
    
    trait :published do
      approved
      starts_at { DateTime.now.beginning_of_day }
      ends_at { 30.days.from_now }
      visibility CampaignDraft::PUBLIC_VISIBILITY
      generate_invite_link false
      time_zone { Estiu::Timezones::ALL.sample }
      starts_immediately false
      published_at { DateTime.now }
    end
    
  end
  
end