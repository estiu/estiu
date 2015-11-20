# An "Artist" is optional, extended data about a RaArtist.
class Artist < ActiveRecord::Base
  
  has_and_belongs_to_many :artist_promoters, join_table: :artist_catalog_entries
  belongs_to :ra_artist
  
  %i(name telephone email website ra_artist_id).each do |attr|
    validates attr, presence: true
  end
  
  def to_s
    name
  end
    
end
