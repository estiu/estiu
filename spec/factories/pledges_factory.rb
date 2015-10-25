FG.define do
  
  factory :pledge do
    
    association :attendee
    association :campaign
    stripe_charge_id { SecureRandom.hex }
    
    after(:build) do |rec, eva|
      rec.amount_cents = rec.originally_pledged_cents = rec.campaign.minimum_pledge_cents unless rec.amount_cents
      rec.originally_pledged_cents = rec.amount_cents unless rec.originally_pledged_cents
    end
      
  end
  
end