FG.define do
  
  factory :campaign do
    
    association :campaign_draft
    
    trait :with_event do
      
      after(:create) do |rec, eva|
        FG.create :event, campaign: rec, event_promoter_id: rec.event_promoter.id
      end
      
    end
    
    trait :with_submitted_event do
      
      after(:create) do |rec, eva|
        FG.create :event, :submitted, campaign: rec
      end
      
    end
    
    trait :fulfilled do
      
      transient do
        including_attendees []
      end
      
      after(:create) do |rec, eva|
        
        fail if rec.fulfilled?
        
        pledge_count = 5
        amount_cents = (rec.goal_cents.to_f / pledge_count.to_f).floor
        
        (pledge_count - eva.including_attendees.size).times {
          rec.pledges << FG.create(:pledge, campaign: rec, amount_cents: amount_cents)
        }
        
        eva.including_attendees.each do |attendee|
          rec.pledges << FG.create(:pledge, campaign: rec, amount_cents: amount_cents, attendee: attendee)
        end
        
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
    
    trait :unfulfilled do
      
      transient do
        including_attendees []
      end
      
      after(:create) do |rec, eva|
        
        rec.campaign_draft.update_attributes! starts_at: 30.days.ago, ends_at: 2.days.ago
        
        pledge_count = 5
        amount_cents = ((rec.goal_cents - rec.minimum_pledge_cents - 1).to_f / pledge_count.to_f).floor
        
        (pledge_count - eva.including_attendees.size).times {
          rec.pledges << FG.create(:pledge, campaign: rec, amount_cents: amount_cents)
        }
        
        eva.including_attendees.each do |attendee|
          rec.pledges << FG.create(:pledge, campaign: rec, amount_cents: amount_cents, attendee: attendee)
        end
        
      end
      
      after(:create) do |rec, eva|
        fail if rec.fulfilled?
        CampaignUnfulfillmentCheck.run
        fail unless rec.reload.unfulfilled_at
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