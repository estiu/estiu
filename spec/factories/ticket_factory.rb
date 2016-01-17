FG.define do
  
  factory :ticket do
    
    association :attendee
    
    after(:build) do |rec, eva|
      rec.event ||= FG.create(:event, :submitted, :approved)
    end
    
    after(:create) do |rec, eva|
      unless rec.attendee.pledge_for(rec.event.campaign)
        FG.create(:pledge, campaign: rec.event.campaign, attendee: rec.attendee)
      end
    end
    
  end
  
end