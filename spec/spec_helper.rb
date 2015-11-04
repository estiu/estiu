ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

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

RSpec.configure do |config|
  
  config.include ActionView::Helpers::TranslationHelper
  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers, type: :feature
  config.render_views  
  config.infer_spec_type_from_file_location!
  config.default_retry_count = 2
  
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    FactoryGirl.lint
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

end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
