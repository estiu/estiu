class ArtistPromoter < ActiveRecord::Base
  
  has_and_belongs_to_many :artists, join_table: :artist_catalog_entries
  
  has_many :contacts, as: :contactable
  
end
