module ActiveModel
  module Validations

    class FileContentTypeValidator < ActiveModel::EachValidator
      def initialize(options)
        super
      end

      def self.helper_method_name
        :validates_file_content_type
      end

      def validate_each(record, attribute, value)
        unless value.blank?
          content_type = value.content_type
          validate_whitelist(record, attribute, content_type)
          validate_blacklist(record, attribute, content_type)
        end
      end

      def validate_whitelist(record, attribute, value)
        allowed_types = [options_call(record, :allow)].flatten.compact
        if allowed_types.present? && allowed_types.none? { |type| type === value }
          record.errors.add attribute, :allowed_file_content_types, options.merge(:types => allowed_types.join(', '))
        end
      end

      def validate_blacklist(record, attribute, value)
        forbidden_types = [options_call(record, :exclude)].flatten.compact
        if forbidden_types.present? && forbidden_types.any? { |type| type === value }
          record.errors.add attribute, :excluded_file_content_types, options.merge(:types => forbidden_types.join(', '))
        end
      end

      def options_call(record, key)
        options[key].is_a?(Proc) ? options[key].call(record) : options[key]
      end

      def check_validity!
        unless options.has_key?(:allow) || options.has_key?(:exclude)
          raise ArgumentError, 'You must pass in either :allow or :exclude to the validator'
        end
      end
    end

    module HelperMethods
      # Places ActiveModel validations on the content type of the file
      # assigned. The possible options are:
      # * +allow+: Allowed content types.  Can be a single content type
      #   or an array.  Each type can be a String or a Regexp. It should be
      #   noted that Internet Explorer uploads files with content_types that you
      #   may not expect. For example, JPEG images are given image/pjpeg and
      #   PNGs are image/x-png, so keep that in mind when determining how you
      #   match.  Allows all by default.
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
