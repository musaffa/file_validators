require 'active_model'
require 'ostruct'

module FileValidators
  module Utils
    extend ActiveSupport::Autoload

    autoload :ContentTypeDetector
    autoload :MediaTypeSpoofDetector
  end
end

Dir[File.dirname(__FILE__) + "/file_validators/validators/*.rb"].each { |file| require file }

locale_path = Dir.glob(File.dirname(__FILE__) + '/file_validators/locale/*.yml')
I18n.load_path += locale_path unless I18n.load_path.include?(locale_path)
