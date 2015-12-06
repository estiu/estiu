require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

if Rails.env.development?
  Sidekiq.redis &:info rescue raise "Redis not running."
end

module Events
  class Application < Rails::Application
    
    def self.host
      case Rails.env
      when 'production', 'staging'
        'estiu.com'
      when 'test', 'development'
        'localhost'
      end
    end
    
    def self.port
      if Rails.env.development?
        3000
      elsif Rails.env.test?
        56866
      else
        nil
      end
    end
    
    config.active_record.raise_in_transactional_callbacks = true
    config.generators do |g|
      g.test_framework nil
    end
    
    config.middleware.use Rack::ContentLength
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.default_url_options ||= {}
    config.action_mailer.default_url_options[:host] = host
    config.action_mailer.default_url_options[:port] = port if port
    config.action_mailer.preview_path = "#{Rails.root}/app/mailer_previews"
    Rails.application.routes.default_url_options[:host] = host
    Rails.application.routes.default_url_options[:port] = port if port
    
  end
end
