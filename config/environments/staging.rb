require_relative 'production_or_staging'

Rails.application.configure do
  config.action_mailer.raise_delivery_errors = false
  config.active_job.queue_adapter = DeveloperMachine.running_in_developer_machine? ? :inline : :shoryuken
end
