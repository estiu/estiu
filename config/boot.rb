ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'rails/commands/server' # require rails, for `if Rails.env.development? || Rails.env.test?` below
require_relative '../app/lib/developer_machine'

unless ENV["RAILS_ENV"] == "test"
  
  unless File.exists?(File.join(Dir.pwd, 'Gemfile'))
    raise 'Please start Rails from the project root directory.'
  end
  
  in_developer_machine = DeveloperMachine.running_in_developer_machine?
  
  rails_env_file = File.join(Dir.pwd, 'RAILS_ENV')
  
  if File.exists?(rails_env_file)
    
    raise "Don't have a RAILS_ENV file in your development machine / in version control." if in_developer_machine
    
    ENV["RAILS_ENV"] = File.read(rails_env_file).split("\n")[0]
    
    raise "Don't run #{Rails.env} env in a production/staging server." if Rails.env.development? || Rails.env.test?
    
  else
    raise 'Please define the environment in which the server should be run in a RAILS_ENV file.' unless in_developer_machine
  end
  
end

module Rails
  class Server
    def default_options
      super.merge(Port: 4000)
    end
  end
end