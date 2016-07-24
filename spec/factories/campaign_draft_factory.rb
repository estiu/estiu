FG.define do
  
  factory :campaign_draft do
    
    association :event_promoter
    association :venue
    names = ['Fund my party', 'Help me out with this event idea', 'Awesome night proposal', 'Ravers unite!', 'Sample campaign', 'My Campaign', 'Awesome Campaign', 'Crowdfund my event!']
    name { names.sample }
    description "I was thinking of throwing the perfect party, in a great open-air venue, at daytime, and with some of the latest and greatest DJs out there."
    proposed_goal_cents { Random.rand(CampaignDraft::MAXIMUM_GOAL_AMOUNT - CampaignDraft::MINIMUM_GOAL_AMOUNT).to_i + CampaignDraft::MINIMUM_GOAL_AMOUNT}
    cost_justification {
      %|
  #{SecureRandom.hex} => a few cents
  #{SecureRandom.hex} => some more euros
  #{SecureRandom.hex} => very costly
|
    }
    skip_past_date_validations true
    
    after(:build) do |rec, eva|
      rec.minimum_pledge_cents = [(rec.proposed_goal_cents.to_f / rec.venue.capacity.to_f).ceil, Pledge::STRIPE_MINIMUM_PAYMENT].max
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
      estimated_event_date { 32.days.from_now.to_date }
      estimated_event_hour { (0..23).to_a.sample }
      estimated_event_minutes { (0..59).to_a.sample }
    end
    
  end
  
end