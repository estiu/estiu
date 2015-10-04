class ArtistCatalogEntry < ActiveRecord::Base
  
  belongs_to :artist
  belongs_to :artist_promoter
  
  def self.default_act_duration
    150.minutes
  end
  
end
