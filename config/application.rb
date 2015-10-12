require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Events
  class Application < Rails::Application
    
    config.active_record.raise_in_transactional_callbacks = true
    config.generators do |g|
      g.test_framework nil
    end
    
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 } # devise advises to fill this at some point
    
  end
end
