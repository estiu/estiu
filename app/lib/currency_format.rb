class CurrencyFormat
  
  EUROPE = 'europe'.freeze
  USA_UK = 'usa_uk'.freeze
  DEFAULT_CONVENTION = EUROPE
  
  DECIMAL_SEPARATORS = {
    EUROPE => ',',
    USA_UK => '.'
  }.freeze
  
  THOUSANDS_DELIMITERS = {
    EUROPE => '.',
    USA_UK => ','
  }.freeze
  
  def self.default_thousands_delimiter
    THOUSANDS_DELIMITERS[DEFAULT_CONVENTION]
  end
  
  def self.default_decimal_separator
    DECIMAL_SEPARATORS[DEFAULT_CONVENTION]
  end
  
  def self.js_options convention=DEFAULT_CONVENTION
    {
      aSep: THOUSANDS_DELIMITERS[convention],
      aDec: DECIMAL_SEPARATORS[convention]
    }.to_json
  end
  
end