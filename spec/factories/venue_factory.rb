FG.define do
  
  factory :venue do
    
    names = ["Nitsa", 'Moog', 'Razzmatazz', 'Ker', 'City Hall', 'Poble Espanyol - Picnic Area', 'Poble Espanyol - Monasterio', 'Poble Espanyol - Plaza Mayor']
    name { "#{names.sample} #{SecureRandom.hex(3)}" }
    address "Nou de la Rambla"
    description "Barcelona's most respected underground club."
    capacity { (Random.rand * 400).to_i + 100 }
    
  end
  
end