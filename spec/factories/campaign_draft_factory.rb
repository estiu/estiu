FG.define do
  
  factory :campaign_draft do
    
    association :event_promoter
    association :venue
    submitted_at { DateTime.now }
    name "Fund my party"
    description "I was thinking of throwing the perfect party, in a great open-air venue, at daytime, and with some of the latest and greatest DJs out there."
    starts_at { DateTime.now.beginning_of_day }
    ends_at { 30.days.from_now }
    goal_cents { Random.rand(CampaignDraft::MAXIMUM_GOAL_AMOUNT - CampaignDraft::MINIMUM_GOAL_AMOUNT).to_i + CampaignDraft::MINIMUM_GOAL_AMOUNT}
    skip_past_date_validations true
    visibility CampaignDraft::PUBLIC_VISIBILITY
    generate_invite_link false
    starts_immediately false
    time_zone { Estiu::Timezones::ALL.sample }
    
    after(:build) do |rec, eva|
      rec.minimum_pledge_cents = [(rec.goal_cents / rec.venue.capacity).ceil, Pledge::STRIPE_MINIMUM_PAYMENT].max
    end
    
    trait :step_1 do
      
      after(:build) do |rec, eva|
        CampaignDraft::CREATE_ATTRS_STEP_2.each do |attr|
          rec.send "#{attr}=", nil
          rec.submitted_at = nil
        end
      end
      
    end
    
  end
  
end