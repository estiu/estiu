ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'spec_helper'
require 'rspec/rails'
require 'webmock/rspec'
require 'capybara/rails'
require 'capybara/rspec'

ActiveRecord::Migration.maintain_test_schema!

WebMock.disable_net_connect!(allow_localhost: true)

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
    DatabaseCleaner.strategy = example.metadata[:js] ? :truncation : :transaction
    DatabaseCleaner.start
    Warden.test_mode!
  end

  config.after(:each) do
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

def controller_ok status=200
  expect(response.status).to be status
  expect(response.body).to be_present
end

def assign_devise_mapping
  before {
    @request.env["devise.mapping"] = Devise.mappings[:user]
  }
end

def sign_as role_name=nil, js=false
  
  return unless role_name # nil means signed out user
  
  let(role_name) { FG.create(:user, "#{role_name}_role".to_sym) }
  
  before do
    user_object = eval(role_name.to_s)
    user_object.confirm
    if js
      login_as(user_object, scope: :user)
    else
      sign_in :user, user_object
    end
  end
  
end

def expect_unauthorized
  expect(subject).to receive(:user_not_authorized).once.with(any_args).and_call_original
  expect(subject).to rescue_from(Pundit::NotAuthorizedError).with :user_not_authorized
end

def forbidden_for *role_names

  role_names.each do |role|
    
    context "sign_as #{role || "nil"}" do
      
      it 'is forbidden' do
        
        expect(response.status).to be 302
        expect(flash[:alert]).to include(t('application.forbidden'))
        
      end
      
    end
    
  end
  
end
