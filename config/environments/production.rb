require_relative 'production_or_staging'

Rails.application.configure do
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.smtp_settings = {
    address: 'smtp.mandrillapp.com',
    port: 587,
    user_name: "vemv@vemv.net",
    password: Rails.application.secrets.mandrill_api_key,
    authentication: :plain
  }
end
