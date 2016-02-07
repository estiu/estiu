class Estiu::Timezones
  
  ALL_TIMEZONE_OBJECTS = ActiveSupport::TimeZone.all
  ALL = ALL_TIMEZONE_OBJECTS.map(&:tzinfo).map(&:name).uniq.sort
  FOR_SELECT = ALL_TIMEZONE_OBJECTS.map{|tz| [tz.to_s, tz.tzinfo.name] }.uniq.sort
  
end