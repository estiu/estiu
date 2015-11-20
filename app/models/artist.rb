class Artist < ActiveRecord::Base
  
  has_and_belongs_to_many :events
  has_and_belongs_to_many :artist_promoters, join_table: :artist_catalog_entries
  has_one :user
  belongs_to :resident_advisor_path
  
  %i(name telephone email website user resident_advisor_path_id).each do |attr|
    validates attr, presence: true
  end
  
  def to_s
    name
  end
    
end
