# https://github.com/plataformatec/devise/blob/master/lib/generators/templates/devise.rb
Devise.setup do |config|
  config.mailer_sender = 'vemv@vemv.net'
  require 'devise/orm/active_record'
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = Rails.env.development? ? 1..72 : 8..72
  config.reset_password_within = 6.hours
  config.sign_out_via = :get
  config.secret_key = Rails.application.secrets.devise_secret_key
end
