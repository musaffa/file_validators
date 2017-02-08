ENV['RAILS_ENV'] ||= 'test'

require 'active_support'
require 'active_support/deprecation'
require 'active_support/core_ext'
require 'file_validators'
require 'rspec'
require 'coveralls'

Coveralls.wear!

locale_path = Dir.glob(File.dirname(__FILE__) + '/locale/*.yml')
I18n.load_path += locale_path unless I18n.load_path.include?(locale_path)
I18n.enforce_available_locales = false

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Suppress stdout in the console
  config.before { allow($stdout).to receive(:write) }
end
