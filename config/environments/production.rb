Rails.application.configure do
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.serve_static_files = true
  config.assets.js_compressor = :uglifier
  config.assets.compile = false
  config.assets.digest = true
  config.log_level = :debug
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.active_record.dump_schema_after_migration = false
  config.active_job.queue_adapter = :shoryuken
  config.action_mailer.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: 587,
    user_name: "vemv@vemv.net",
    password: Rails.application.secrets.mandrill_api_key,
    authentication: :plain
  }
end
