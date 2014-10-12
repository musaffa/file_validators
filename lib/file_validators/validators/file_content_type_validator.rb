module ActiveModel
  module Validations

    class FileContentTypeValidator < ActiveModel::EachValidator
      CHECKS = [:allow, :exclude].freeze

      def self.helper_method_name
        :validates_file_content_type
      end

      def validate_each(record, attribute, value)
        unless value.blank?
          allowed_types = option_content_types(record, :allow)
          forbidden_types = option_content_types(record, :exclude)
          file_type = value.content_type

          validate_whitelist(record, attribute, file_type, allowed_types)
          validate_blacklist(record, attribute, file_type, forbidden_types)
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

      def option_content_types(record, key)
        [option_value(record, key)].flatten.compact
      end

      def option_value(record, key)
        options[key].is_a?(Proc) ? options[key].call(record) : options[key]
      end

      def validate_whitelist(record, attribute, file_type, allowed_types)
        if allowed_types.present? and allowed_types.none? { |type| type === file_type }
          mark_invalid record, attribute, :allowed_file_content_types, allowed_types
        end
      end

      def validate_blacklist(record, attribute, file_type, forbidden_types)
        if forbidden_types.any? { |type| type === file_type }
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
