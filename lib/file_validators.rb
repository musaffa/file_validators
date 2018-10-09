# frozen_string_literal: true

require 'active_model'
require 'ostruct'

module FileValidators
  extend ActiveSupport::Autoload
  autoload :Error
  autoload :MimeTypeAnalyzer
end

Dir[File.dirname(__FILE__) + '/file_validators/validators/*.rb'].each { |file| require file }

locale_path = Dir.glob(File.dirname(__FILE__) + '/file_validators/locale/*.yml')
I18n.load_path += locale_path unless I18n.load_path.include?(locale_path)
