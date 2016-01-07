require 'file_validators/utils/content_type_detector'
require 'file_validators/utils/media_type_spoof_detector'
require 'file_validators/utils/file_command_content_type_detector'

module ActiveModel
  module Validations

    class FileContentTypeValidator < ActiveModel::EachValidator
      CHECKS = [:allow, :exclude].freeze

      def self.helper_method_name
        :validates_file_content_type
      end

      def validate_each(record, attribute, value)
        value = JSON.parse(value) if value.is_a?(String) && value.present?
        unless value.blank?
          mode = option_value(record, :mode)
          content_type = get_content_type(value, mode)
          allowed_types = option_content_types(record, :allow)
          forbidden_types = option_content_types(record, :exclude)

          validate_media_type(record, attribute, content_type, get_file_name(value)) if mode == :strict
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

      def get_file_path(value)
        temp_object = value.try(:tempfile) || Paperclip.io_adapters.for(value)

        if temp_object.respond_to?(:path)
          temp_object.path
        else
          raise ArgumentError, 'value must return a file path in order to validate file content type'
        end
      end

      def get_file_name(value)
        if value.try(:original_filename)
          value.original_filename
        else
          File.basename(get_file_path(value))
        end
      end

      def get_content_type(value, mode)
        case mode
        when :strict
          file_path = get_file_path(value)
          FileValidators::Utils::ContentTypeDetector.new(file_path).detect
        when :relaxed
          file_name = get_file_name(value)
          MIME::Types.type_for(file_name).first
        else
          value = OpenStruct.new(value) if value.is_a?(Hash)
          value.content_type
        end
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
      # * +mode+: :strict or :relaxed.
      #   :strict mode validates the content type based on the actual contents
      #   of the files. Thus it can detect media type spoofing.
      #   :relaxed validates the content type based on the file name using
      #   the mime-types gem. It's only for sanity check.
      #   If mode is not set then it uses form supplied content type.
      # * +if+: A lambda or name of an instance method. Validation will only
      #   be run is this lambda or method returns true.
      # * +unless+: Same as +if+ but validates if lambda or method returns false.
      def validates_file_content_type(*attr_names)
        validates_with FileContentTypeValidator, _merge_attributes(attr_names)
      end
    end

  end
end
