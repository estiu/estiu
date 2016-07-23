FG.define do
  
  factory :venue do
    
    names = ["Nitsa", 'Moog', 'Razzmatazz', 'Ker', 'City Hall', 'Poble Espanyol - Picnic Area', 'Poble Espanyol - Monasterio', 'Poble Espanyol - Plaza Mayor']
    name { "#{names.sample} #{SecureRandom.hex(3)}" }
    addresses = ["Nou de la Rambla", "Almogavers", "Las Ramblas", "Arc de Teatre", "Carrer Paris", "Carrer de la Marina", "c/ Princesa", "La Sagrada Familia"]
    address { addresses.sample }
    descs = ["Barcelona's most respected underground club.", "An awesome venue", "20 years in the business", "Open air", "A nice chiringuito", "A new club in town"]
    description { descs.sample }
    capacity { (Random.rand * 400).to_i + 100 }
    
  end
  
end