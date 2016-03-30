module ActiveModel
  module Validations

    class FileSizeValidator < ActiveModel::EachValidator
      CHECKS = { in: :===,
                 less_than: :<,
                 less_than_or_equal_to: :<=,
                 greater_than: :>,
                 greater_than_or_equal_to: :>= }.freeze

      def self.helper_method_name
        :validates_file_size
      end

      def validate_each(record, attribute, value)
        value = JSON.parse(value) if value.is_a?(String) && value.present?
        unless value.blank?
          options.slice(*CHECKS.keys).each do |option, option_value|
            value = OpenStruct.new(value) if value.is_a?(Hash)
            option_value = option_value.call(record) if option_value.is_a?(Proc)
            unless valid_size?(value.size, option, option_value)
              record.errors.add(attribute,
                                "file_size_is_#{option}".to_sym,
                                filtered_options(value).merge!(detect_error_options(option_value)))
            end
          end
        end
      end

      def check_validity!
        unless (CHECKS.keys & options.keys).present?
          raise ArgumentError, 'You must at least pass in one of these options - :in, :less_than,
                                :less_than_or_equal_to, :greater_than and :greater_than_or_equal_to'
        end

        check_options(Numeric, options.slice(*(CHECKS.keys - [:in])))
        check_options(Range, options.slice(:in))
      end

      private

      def check_options(klass, options)
        options.each do |option, value|
          unless value.is_a?(klass) || value.is_a?(Proc)
            raise ArgumentError, ":#{option} must be a #{klass.name.to_s.downcase} or a proc"
          end
        end
      end

      def valid_size?(size, option, option_value)
        if option_value.is_a?(Range)
          option_value.send(CHECKS[option], size)
        else
          size.send(CHECKS[option], option_value)
        end
      end

      def filtered_options(value)
        filtered = options.except(*CHECKS.keys)
        filtered[:value] = value
        filtered
      end

      def detect_error_options(option_value)
        if option_value.is_a?(Range)
          { min: human_size(option_value.min), max: human_size(option_value.max)  }
        else
          { count: human_size(option_value) }
        end
      end

      def human_size(size)
        if defined?(ActiveSupport::NumberHelper) # Rails 4.0+
          ActiveSupport::NumberHelper.number_to_human_size(size)
        else
          storage_units_format = I18n.translate(:'number.human.storage_units.format', :locale => options[:locale], :raise => true)
          unit = I18n.translate(:'number.human.storage_units.units.byte', :locale => options[:locale], :count => size.to_i, :raise => true)
          storage_units_format.gsub(/%n/, size.to_i.to_s).gsub(/%u/, unit).html_safe
        end
      end

    end

    module HelperMethods
      # Places ActiveModel validations on the size of the file assigned. The
      # possible options are:
      # * +in+: a Range of bytes (i.e. +1..1.megabyte+),
      # * +less_than_or_equal_to+: equivalent to :in => 0..options[:less_than_or_equal_to]
      # * +greater_than_or_equal_to+: equivalent to :in => options[:greater_than_or_equal_to]..Infinity
      # * +less_than+: less than a number in bytes
      # * +greater_than+: greater than a number in bytes
      # * +message+: error message to display, use :min and :max as replacements
      # * +if+: A lambda or name of an instance method. Validation will only
      #   be run if this lambda or method returns true.
      # * +unless+: Same as +if+ but validates if lambda or method returns false.
      def validates_file_size(*attr_names)
        validates_with FileSizeValidator, _merge_attributes(attr_names)
      end
    end

  end
end
