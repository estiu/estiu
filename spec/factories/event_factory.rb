FG.define do
  
  factory :event do
    
    name { ["Best party ever", 'Super outdoor event', 'House party', 'Club night', 'Rave in the woods', 'Boat party', 'Mega festival'].sample }
    starts_at {Date.tomorrow}
    duration {6.hours}
    association :venue
    
    transient do
      event_promoter_id nil
    end
    
    after(:build) do |rec, eva|
      
      unless rec.campaign
        opts = {}
        opts.merge!(event_promoter_id: eva.event_promoter_id) if eva.event_promoter_id
        rec.campaign = FG.build(:campaign, opts)
      end
      
      if rec.resident_advisor_paths.size.zero?
        
        3.times {
          rec.resident_advisor_paths << FG.build(:resident_advisor_path)
        }
        
      end
      
    end
    
  end
  
end