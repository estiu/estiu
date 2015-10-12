class Roles
  
  def self.all
    %i(event_promoter attendee)
  end
  
  self.all.each do |role|
    define_singleton_method role do
      role
    end
  end
  
end