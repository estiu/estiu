source 'https://rubygems.org'

ruby "2.3.0"

# Gemfile.lock should be periodically checked against isitvulnerable.com.

gem 'activerecord-session_store', '~> 0.1'
gem 'aws-sdk', '~> 2.1'
gem 'bootstrap-sass', '~> 3.3'
gem 'browser', '~> 1'
gem 'carrierwave', '~> 0.10'
gem 'carrierwave_direct', '~> 0'
gem 'devise', '~> 3.5'
gem 'dotenv-rails', '~> 2'
gem 'factory_girl_rails', '~> 4.5'
gem 'haml-rails', '~> 0.9'
gem 'high_voltage', '~> 2.4'
gem 'jquery-fileupload-rails', '0.4.6' # exact version - we don't want JS files to be auto updated
gem 'jquery-rails', '~> 4'
gem 'jquery-ui-rails', '~> 5'
gem 'money-rails', '~> 1.4'
gem 'oj', '~> 2.12' # for rollbar
gem 'okcomputer', '~> 1.17'
gem 'omniauth', '~> 1.2'
gem 'omniauth-facebook', '~> 3'
gem 'pg', '~> 0.18'
gem 'pundit', '~> 1'
gem 'rails', '~> 4.2.5'
gem 'redcarpet', '~> 3.3', require: 'tilt/redcarpet'
gem 'rollbar', '~> 2.4'
gem 'sass-rails', '~> 5'
gem 'shoryuken', github: 'phstc/shoryuken'
gem 'sidekiq', '~> 3.5'
gem 'stripe', '~> 1'
gem 'therubyracer', '~> 0.12'
gem 'uglifier', '~> 2.7'
gem 'unicorn', '~> 5'
gem 'validates_formatting_of', '~> 0.9'

group :development, :test, :staging do
  gem 'pry'
  gem 'pry-rails'
  gem 'pry-stack_explorer'
  gem 'awesome_print'
end

group :development, :test do
  gem 'quiet_assets'
end

group :development do
  # gem 'better_errors' # disabled until nginx fixed
  gem 'binding_of_caller'
  gem 'sql-logging'
end

group :test do
  gem 'rspec-rails', '~> 3.3'
  gem 'shoulda-matchers', '~> 3'
  gem 'rspec-retry', '~> 0.4'
  gem 'webmock', '~> 1.21'
  gem 'capybara', '~> 2.5'
  gem 'launchy', '~> 2.4'
  gem 'selenium-webdriver', '~> 2.47'
  gem 'database_cleaner', '~> 1.5'
  gem 'simplecov', '~> 0.10', require: false
end
