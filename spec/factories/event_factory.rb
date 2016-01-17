FG.define do
  
  factory :event do
    
    name { ["Best party ever", 'Super outdoor event', 'House party', 'Club night', 'Rave in the woods', 'Boat party', 'Mega festival'].sample }
    starts_at {Date.tomorrow}
    duration {6.hours}
    association :venue
    
    transient do
      event_promoter_id nil
    end
    
    trait :submitted do
      
      after(:build) do |rec, eva|
        rec.submitted_at = DateTime.now
        if rec.event_documents.size.zero?
          rec.event_documents << FG.build(:event_document, event: rec)
        end
      end
      
    end
    
    trait :approved do
      
      after(:create) do |rec, eva|
        rec.reload.update_attributes!(approved_at: DateTime.now)
      end
      
    end
    
    trait :rejected do
      
      after(:create) do |rec, eva|
        rec.reload.update_attributes!(rejected_at: DateTime.now)
      end
      
    end
    
    after(:build) do |rec, eva|
      
      unless rec.campaign
        opts = {}
        opts.merge!(event_promoter_id: eva.event_promoter_id) if eva.event_promoter_id
        rec.campaign = FG.create(:campaign, :fulfilled, opts)
      end
      
      if rec.ra_artists.size.zero?
        
        3.times {
          rec.ra_artists << FG.build(:ra_artist)
        }
        
      end
      
    end
    
  end
  
end