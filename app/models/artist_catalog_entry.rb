class ArtistCatalogEntry < ActiveRecord::Base
  
  belongs_to :artist
  belongs_to :artist_promoter
  
  monetize :price_cents
  
  %i(price_cents act_duration artist artist_promoter).each do |attr|
    validates attr, presence: true
  end
  
  def self.default_act_duration
    150.minutes
  end
  
end
