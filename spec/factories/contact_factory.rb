FG.define do
  
  factory :contact do
    
    first_name "Foo"
    last_name "Bar"
    phone "609929302"
    email "foo@bar.com"
    
    after(:build) do |rec, eva|
      unless rec.contactable
        rec.contactable = FG.build :event_promoter, contacts: [rec]
      end
    end
    
  end
  
end