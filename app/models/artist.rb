class Artist < ActiveRecord::Base
  
  has_and_belongs_to_many :events
  has_and_belongs_to_many :artist_promoters, join_table: :artist_catalog_entries
  
end
