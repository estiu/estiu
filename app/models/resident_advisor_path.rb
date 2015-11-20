class ResidentAdvisorPath < ActiveRecord::Base
  
  before_validation :value_format
  validates :value, presence: true, uniqueness: true
  
  PREFIX = 'dj/'
  
  def value_format
    
    return if self.value.blank?
    
    %w(http https www residentadvisor .net).each do |fragment|
      if self.value.include?(fragment)
        errors[:value] << I18n.t("resident_advisor_paths.errors.value_format", found: fragment)
        return
      end
    end
    
    sanitized = Rails::Html::FullSanitizer.new.sanitize self.value
    
    if self.value != sanitized
      errors[:value] << I18n.t("resident_advisor_paths.errors.value_format", found: I18n.t("resident_advisor_paths.errors.html_code"))
      return
    end
    
    if self.value.start_with?('/')
      self.value = self.value[1..(self.value.size - 1)]
    end
    
    if self.value.end_with?('/')
      self.value = self.value[0..(self.value.size - 2)]
    end
    
    unless self.value.start_with?(PREFIX)
      errors[:value] << I18n.t("resident_advisor_paths.errors.dj", prefix: PREFIX)
      return
    end
    
  end

end
