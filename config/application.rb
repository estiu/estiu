require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

module Events
  class Application < Rails::Application
    
    config.active_record.raise_in_transactional_callbacks = true
    config.generators do |g|
      g.test_framework nil
    end
    
    config.middleware.use Rack::ContentLength
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    config.action_mailer.preview_path = "#{Rails.root}/app/mailer_previews"
    
  end
end
