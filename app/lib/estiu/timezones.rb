class Estiu::Timezones
  
  ALL_TIMEZONE_OBJECTS = ActiveSupport::TimeZone.all
  ALL = ALL_TIMEZONE_OBJECTS.map(&:tzinfo).map(&:name).uniq.sort
  PREFERRED_CITIES = [
    "Dublin",
    "Edinburgh",
    "Lisbon",
    "London",
    "Amsterdam",
    "Berlin",
    "Brussels",
    "Madrid",
    "Paris",
    "Athens",
    "Helsinki",
    "Jerusalem",
    "Sofia",
    "Moscow",
    "Sydney",
    "Buenos Aires",
    "Santiago",
    "Eastern Time (US & Canada)",
    "Central Time (US & Canada)",
    "Mountain Time (US & Canada)",
    "Pacific Time (US & Canada)"
  ]
  FOR_SELECT = ALL_TIMEZONE_OBJECTS.map{|tz| [tz.to_s, tz.tzinfo.name] }.uniq.sort.group_by{|a| a[0][0..10] }.map{|k, v| [k, v[0].second, v.map{|a|  a.first }.map{|a| a[12..(a.length - 1)]}.select{|a| PREFERRED_CITIES.include?(a)} ] }.sort_by{|a| [(a[2].blank? ? "b" : "a"), a[0]] }.map{|a| a[2] = [a[0]] if a[2].blank?; [a[2].sort.join(', '), a[1]] }
  
end

