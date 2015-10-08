module ResettableDates
  
  def self.extended(base)
    base.class_eval do
      
      self::DATE_ATTRS.each do |attr|
        attr_accessor "#{attr}_not_given".to_sym
        attr_accessor "#{attr}_4i"
        attr_accessor "#{attr}_5i"
      end
      
      before_validation :resettable_dates

      def resettable_dates
        self.class::DATE_ATTRS.each do |attr|
          if self.send("#{attr}_not_given")
            self.send("#{attr}=", nil) unless Causality.checking?("ResettableDates#resettable_dates")
          end
        end
      end
      
    end
  end
  
end