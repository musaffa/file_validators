require 'active_model'
require 'mimemagic'
require 'mimemagic/overlay'
require 'file_validators/validators/file_size_validator'
require 'file_validators/validators/file_content_type_validator'

locale_path = Dir.glob(File.dirname(__FILE__) + '/file_validators/locale/*.yml')
I18n.load_path += locale_path unless I18n.load_path.include?(locale_path)
