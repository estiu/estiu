class Roles
  
  def self.all
    %i(event_promoter)
  end
  
  self.all.each do |role|
    define_singleton_method role do
      role
    end
  end
  
end