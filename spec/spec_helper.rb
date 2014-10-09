ENV['RAILS_ENV'] ||= 'test'

require 'active_support'
require 'active_support/core_ext'
require_relative '../lib/file_validators'
require 'rspec'
require 'coveralls'

Coveralls.wear!

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
end
