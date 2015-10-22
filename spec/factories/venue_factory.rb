FG.define do
  
  factory :venue do
    
    name "Nitsa"
    address "Nou de la Rambla"
    description "Barcelona's most respected underground club."
    capacity { (Random.rand * 400).to_i + 100 }
    
  end
  
end