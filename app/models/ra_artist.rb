class RaArtist < ActiveRecord::Base
  
  PREFIX = 'dj/'
  
  before_validation :artist_path_format
  validates :artist_path, presence: true, uniqueness: true
  validates :artist_name, presence: true, uniqueness: true
  
  before_validation :copy_artist_name
  
  def artist_path_format
    
    return if self.artist_path.blank?
    
    %w(http https www residentadvisor .net).each do |fragment|
      if self.artist_path.include?(fragment)
        errors[:artist_path] << I18n.t("ra_artists.errors.artist_path_format", found: fragment)
        return
      end
    end
    
    sanitized = Rails::Html::FullSanitizer.new.sanitize self.artist_path
    
    if self.artist_path != sanitized
      errors[:artist_path] << I18n.t("ra_artists.errors.artist_path_format", found: I18n.t("ra_artists.errors.html_code"))
      return
    end
    
    if self.artist_path.start_with?('/')
      self.artist_path = self.artist_path[1..(self.artist_path.size - 1)]
    end
    
    if self.artist_path.end_with?('/')
      self.artist_path = self.artist_path[0..(self.artist_path.size - 2)]
    end
    
    unless self.artist_path.start_with?(PREFIX)
      errors[:artist_path] << I18n.t("ra_artists.errors.dj", prefix: PREFIX)
      return
    end
    
  end
  
  def copy_artist_name
    unless self.artist_name.present?
      self.artist_name = self.artist_path.gsub(PREFIX, '')
    end
  end
  
end
