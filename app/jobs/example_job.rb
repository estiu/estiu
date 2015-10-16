class ExampleJob < ActiveJob::Base
  
  def perform *_ # usage: .perform_later
    puts "Foo!"
  end
  
end