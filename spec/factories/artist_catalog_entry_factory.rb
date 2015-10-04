FG.define do
  
  factory :artist_catalog_entry do
    
    association :artist
    association :artist_promoter
    
    price_cents { 1000_00 }
    act_duration { ArtistCatalogEntry.default_act_duration }
    
  end
  
end