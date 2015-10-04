class ArtistCatalogEntry < ActiveRecord::Base
  
  belongs_to :artist
  belongs_to :artist_promoter
  
  %i(price_cents act_duration).each do |attr|
    validates attr, presence: true
  end
  
  def self.default_act_duration
    150.minutes
  end
  
end
