require File.expand_path('../boot', __FILE__)

require 'rails/all'

Bundler.require(*Rails.groups)

if Rails.env.development?
  Sidekiq.redis &:info rescue raise "Redis not running."
end

module Estiu
  class Application < Rails::Application
    
    def self.host
      case Rails.env
      when 'production'
        'www.estiu.events'
      when 'staging'
        'staging.estiu.events'
      when 'development'
        false ?
          Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address : # for mobile access
          'localhost'
      when 'test'
        'localhost'
      end
    end
    
    def self.port
      if Rails.env.development?
        8080
      elsif Rails.env.test?
        56866
      else
        nil
      end
    end
    
    def nginx_prefix
      if Rails.env.development?
        '/estiu'
      else
        ''
      end
    end
    
    def self.protocol
      'http'
    end

    config.active_record.raise_in_transactional_callbacks = true
    config.generators do |g|
      g.test_framework nil
    end
    
    I18n.enforce_available_locales = true
    I18n.available_locales = [:en]
    I18n.locale = config.i18n.locale = I18n.default_locale = :en
    config.i18n.fallbacks = [:en]
    
    config.time_zone = 'Europe/Madrid'
    config.i18n.load_path += Dir[Rails.root.join('config/locales/**/*.yml').to_s]
    config.middleware.use Rack::ContentLength
    config.active_job.queue_adapter = :sidekiq
    config.action_mailer.default_url_options ||= {}
    config.action_mailer.default_url_options[:host] = host
    config.action_mailer.default_url_options[:port] = port if port
    config.action_mailer.preview_path = "#{Rails.root}/app/mailer_previews"
    config.asset_host = "#{self.protocol}://#{self.host}#{":" + self.port.to_s if self.port}#{nginx_prefix}"
    Rails.application.routes.default_url_options[:host] = host
    Rails.application.routes.default_url_options[:port] = port if port
    
  end
end
