FG.define do
  
  factory :pledge do
    
    association :attendee
    association :campaign
    
    after(:build) do |rec, eva|
      rec.amount_cents = rec.campaign.minimum_pledge_cents unless rec.amount_cents
    end
      
  end
  
end