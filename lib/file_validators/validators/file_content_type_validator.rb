require 'file_validators/utils/content_type_detector'
require 'file_validators/utils/media_type_spoof_detector'

module ActiveModel
  module Validations

    class FileContentTypeValidator < ActiveModel::EachValidator
      CHECKS = [:allow, :exclude].freeze

      def self.helper_method_name
        :validates_file_content_type
      end

      def validate_each(record, attribute, value)
        unless value.blank?
          file_path = get_file_path(value)
          file_name = get_file_name(value)
          content_type = detect_content_type(file_path)
          allowed_types = option_content_types(record, :allow)
          forbidden_types = option_content_types(record, :exclude)

          validate_media_type(record, attribute, content_type, file_name)
          validate_whitelist(record, attribute, content_type, allowed_types)
          validate_blacklist(record, attribute, content_type, forbidden_types)
        end
      end

      def check_validity!
        unless (CHECKS & options.keys).present?
          raise ArgumentError, 'You must at least pass in :allow or :exclude option'
        end

        options.slice(*CHECKS).each do |option, value|
          unless value.is_a?(String) || value.is_a?(Array) || value.is_a?(Regexp) || value.is_a?(Proc)
            raise ArgumentError, ":#{option} must be a string, an array, a regex or a proc"
          end
        end
      end

      private

      def get_attr(value, attr)
        if value.try(attr)
          value.send(attr)
        elsif value.try(:file).try(attr)
          value.file.send(attr)
        end
      end

      def get_file_path(value)
        file_path = get_attr(value, :path)
        # don't allow nil for file_path
        file_path ? file_path : (raise ArgumentError, 'value or value.file must return file path in order to validate file content type')
      end

      def get_file_name(value)
        file_name = get_attr(value, :original_filename)
        file_name ? file_name : File.basename(get_file_path(value))
      end

      def detect_content_type(file_path)
        FileValidators::Utils::ContentTypeDetector.new(file_path).detect
      end

      def option_content_types(record, key)
        [option_value(record, key)].flatten.compact
      end

      def option_value(record, key)
        options[key].is_a?(Proc) ? options[key].call(record) : options[key]
      end

      def validate_media_type(record, attribute, content_type, file_name)
        if FileValidators::Utils::MediaTypeSpoofDetector.new(content_type, file_name).spoofed?
          record.errors.add attribute, :spoofed_file_media_type
        end
      end

      def validate_whitelist(record, attribute, content_type, allowed_types)
        if allowed_types.present? and allowed_types.none? { |type| type === content_type }
          mark_invalid record, attribute, :allowed_file_content_types, allowed_types
        end
      end

      def validate_blacklist(record, attribute, content_type, forbidden_types)
        if forbidden_types.any? { |type| type === content_type }
          mark_invalid record, attribute, :excluded_file_content_types, forbidden_types
        end
      end

      def mark_invalid(record, attribute, error, option_types)
        record.errors.add attribute, error, options.merge(types: option_types.join(', '))
      end
    end

    module HelperMethods
      # Places ActiveModel validations on the content type of the file
      # assigned. The possible options are:
      # * +allow+: Allowed content types. Can be a single content type
      #   or an array. Each type can be a String or a Regexp. It can also
      #   be a proc/lambda. It should be noted that Internet Explorer uploads
      #   files with content_types that you may not expect. For example,
      #   JPEG images are given image/pjpeg and PNGs are image/x-png, so keep
      #   that in mind when determining how you match.
      #   Allows all by default.
      # * +exclude+: Forbidden content types.
      # * +message+: The message to display when the uploaded file has an invalid
      #   content type.
      # * +if+: A lambda or name of an instance method. Validation will only
      #   be run is this lambda or method returns true.
      # * +unless+: Same as +if+ but validates if lambda or method returns false.
      def validates_file_content_type(*attr_names)
        validates_with FileContentTypeValidator, _merge_attributes(attr_names)
      end
    end

  end
end
