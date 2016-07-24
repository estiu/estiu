if (RSpec.configuration.instance_variable_get :@files_or_directories_to_run) == ['spec']
  unless ENV['CODESHIP']
    require 'simplecov'
    SimpleCov.start 'rails' do
      add_filter 'app/lib/aws_ops'
      add_filter 'app/mailer_previews'
    end
  end
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if production_or_staging?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rails'
require 'capybara/rspec'
require 'sidekiq/testing'

include SpecHelpers

ActiveRecord::Migration.maintain_test_schema!

WebMock.disable_net_connect!(allow_localhost: true)

Sidekiq::Testing.inline!

Capybara.server_host = 'localhost' # no 127.0.0.1. Cleaner and FB expects it too
Capybara.server_port = Estiu::Application.port

I18n.t! 'errors.format' # .t is lazy - force it
I18n.backend.store_translations :en, {errors: {format: '%{attribute} %{message}'}}

OmniAuth.config.logger = Logger.new('/dev/null')

RSpec.configure do |config|
  
  config.include ActionView::Helpers::TranslationHelper
  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :feature
  config.render_views  
  config.infer_spec_type_from_file_location!
  
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation) # leave it clean for FactoryGirl
    FactoryGirl.lint
    DatabaseCleaner.clean_with(:truncation) # clean what FactoryGirl created
  end

  config.before(:each) do |example|
    DatabaseCleaner.strategy = (example.metadata[:js] || example.metadata[:truncate]) ? :truncation : :transaction
    DatabaseCleaner.start
    Warden.test_mode!
  end

  config.after(:each) do |example|
    assert_js_ok if example.metadata[:js] && !example.metadata[:skip_js_check]
    DatabaseCleaner.clean
    Warden.test_reset!
  end
  
  config.around :each, :js do |ex|
    ex.run_with_retry retry: (ci? ? 3 : 2), retry_wait: 3
  end
  
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
