module ActiveModel
  module Validations

    class FileSizeValidator < ActiveModel::Validations::NumericalityValidator
      AVAILABLE_CHECKS = [:less_than, :less_than_or_equal_to, :greater_than, :greater_than_or_equal_to].freeze

      def initialize(options)
        extract_options(options)
        super
      end

      def self.helper_method_name
        :validates_file_size
      end

      def validate_each(record, attribute, value)
        unless value.blank?
          options.slice(*AVAILABLE_CHECKS).each do |option, option_value|
            unless value.size.send(CHECKS[option], option_value)
              error_message_key = options[:in] ? :in : option
              record.errors.add(attribute, error_message_key, filtered_options(value).merge!(detect_error_options(option, option_value)))
            end
          end
        end
      end

      def check_validity!
        unless (AVAILABLE_CHECKS + [:in]).any? { |argument| options.has_key?(argument) }
          raise ArgumentError, 'List of allowed options - [:in, :less_than, :greater_than, :less_than_or_equal_to, :greater_than_or_equal_to]'
        end
      end

      private

      def extract_options(options)
        if range = options[:in]
          raise ArgumentError, ':in must be a Range' unless range.is_a?(Range)
          clear_options(options)
          options[:less_than_or_equal_to], options[:greater_than_or_equal_to] = range.max, range.min
        end
      end

      def clear_options(options)
        AVAILABLE_CHECKS.each do |option|
          options.delete(option)
        end
      end

      def detect_error_options(option, option_value)
        if options[:in]
          max = options[:less_than_or_equal_to]
          min =  options[:greater_than_or_equal_to]
          error_options = { min: human_size(min), max: human_size(max)  }
        else
          error_options = { count: human_size(option_value) }
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
