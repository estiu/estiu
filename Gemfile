source 'https://rubygems.org'

ruby "2.2.3"

# Gemfile.lock should be perdiodically checked against isitvulnerable.com.

gem 'rails', '4.2.4'
gem 'pg', '~> 0.18'
gem 'sass-rails', '~> 5'
gem 'uglifier', '~> 2.7'
gem 'jquery-rails', '~> 4'
gem 'jquery-ui-rails', '~> 5'
gem 'factory_girl_rails', '~> 4.5'
gem 'bootstrap-sass', '~> 3.3'
gem 'haml-rails', '~> 0.9'
gem 'redcarpet', '~> 3.3', require: 'tilt/redcarpet'
gem 'high_voltage', '~> 2.4'
gem 'money-rails', '~> 1.4'
gem 'devise', '~> 3.5'
gem 'pundit', '~> 1'
gem 'sidekiq', '~> 3.5'
gem 'stripe', '~> 1'
gem 'browser', '~> 1'
gem 'omniauth', '~> 1.2'
gem 'omniauth-facebook', github: 'gioblu/omniauth-facebook', ref: 'eff97bfae32f72821cbccf0b48b78351e41eb585'

group :development, :test do
  gem 'pry'
  gem 'pry-rails'
  gem 'awesome_print'
  gem 'quiet_assets'
  gem 'dotenv-rails', '~> 2'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'rspec-rails', '~> 3.3.3'
  gem 'shoulda-matchers', '~> 3'
  gem 'rspec-retry', '~> 0.4.4'
  gem 'webmock', '~> 1.21'
  gem 'capybara', '~> 2.5'
  gem 'launchy', '~> 2.4'
  gem 'selenium-webdriver', '~> 2.47'
  gem 'database_cleaner', '~> 1.5'
end
