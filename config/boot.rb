ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'rails/commands/server' # require rails, for `if Rails.env.development? || Rails.env.test?` below
require_relative '../app/lib/developer_machine'

module Rails
  class Server
    def default_options
      super.merge(Port: 4000)
    end
  end
end