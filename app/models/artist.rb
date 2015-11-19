class Artist < ActiveRecord::Base
  
  has_and_belongs_to_many :events
  has_and_belongs_to_many :artist_promoters, join_table: :artist_catalog_entries
  has_one :user
  
  %i(name telephone email website user).each do |attr|
    validates attr, presence: true
  end
  
  def to_s
    name
  end
  
end
