# frozen_string_literal: true

require 'spec_helper'

describe ActiveModel::Validations::FileSizeValidator do
  class Dummy
    include ActiveModel::Validations
  end

  def storage_units
    if defined?(ActiveSupport::NumberHelper) # Rails 4.0+
      { 5120 => '5 KB',       10_240 => '10 KB' }
    else
      { 5120 => '5120 Bytes', 10_240 => '10240 Bytes' }
    end
  end

  before :all do
    @storage_units = storage_units
  end

  subject { Dummy }

  def build_validator(options)
    @validator = described_class.new(options.merge(attributes: :avatar))
  end

  context 'with :in option' do
    context 'as a range' do
      before { build_validator in: (5.kilobytes..10.kilobytes) }

      it { is_expected.to allow_file_size(7.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(4.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(11.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator in: ->(_record) { (5.kilobytes..10.kilobytes) } }

      it { is_expected.to allow_file_size(7.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(4.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(11.kilobytes, @validator) }
    end
  end

  context 'with :greater_than_or_equal_to option' do
    context 'as a number' do
      before { build_validator greater_than_or_equal_to: 10.kilobytes }

      it { is_expected.to allow_file_size(11.kilobytes, @validator) }
      it { is_expected.to allow_file_size(10.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(9.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator greater_than_or_equal_to: ->(_record) { 10.kilobytes } }

      it { is_expected.to allow_file_size(11.kilobytes, @validator) }
      it { is_expected.to allow_file_size(10.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(9.kilobytes, @validator) }
    end
  end

  context 'with :less_than_or_equal_to option' do
    context 'as a number' do
      before { build_validator less_than_or_equal_to: 10.kilobytes }

      it { is_expected.to allow_file_size(9.kilobytes, @validator) }
      it { is_expected.to allow_file_size(10.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(11.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator less_than_or_equal_to: ->(_record) { 10.kilobytes } }

      it { is_expected.to allow_file_size(9.kilobytes, @validator) }
      it { is_expected.to allow_file_size(10.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(11.kilobytes, @validator) }
    end
  end

  context 'with :greater_than option' do
    context 'as a number' do
      before { build_validator greater_than: 10.kilobytes }

      it { is_expected.to allow_file_size(11.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator greater_than: ->(_record) { 10.kilobytes } }

      it { is_expected.to allow_file_size(11.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end
  end

  context 'with :less_than option' do
    context 'as a number' do
      before { build_validator less_than: 10.kilobytes }

      it { is_expected.to allow_file_size(9.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end

    context 'as a proc' do
      before { build_validator less_than: ->(_record) { 10.kilobytes } }

      it { is_expected.to allow_file_size(9.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end
  end

  context 'with :greater_than and :less_than option' do
    context 'as a number' do
      before { build_validator greater_than: 5.kilobytes, less_than: 10.kilobytes }

      it { is_expected.to allow_file_size(7.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(5.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end

    context 'as a proc' do
      before do
        build_validator greater_than: ->(_record) { 5.kilobytes },
                        less_than: ->(_record) { 10.kilobytes }
      end

      it { is_expected.to allow_file_size(7.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(5.kilobytes, @validator) }
      it { is_expected.not_to allow_file_size(10.kilobytes, @validator) }
    end
  end

  context 'with :message option' do
    before do
      build_validator in: (5.kilobytes..10.kilobytes),
                      message: 'is invalid. (Between %{min} and %{max} please.)'
    end

    it do
      is_expected.not_to allow_file_size(
        11.kilobytes, @validator,
        message: "Avatar is invalid. (Between #{@storage_units[5120]}" \
                 " and #{@storage_units[10_240]} please.)"
      )
    end

    it do
      is_expected.to allow_file_size(
        7.kilobytes, @validator,
        message: "Avatar is invalid. (Between #{@storage_units[5120]}" \
                 " and #{@storage_units[10_240]} please.)"
      )
    end
  end

  context 'default error message' do
    context 'given :in options' do
      before { build_validator in: 5.kilobytes..10.kilobytes }

      it do
        is_expected.not_to allow_file_size(
          11.kilobytes, @validator,
          message: "Avatar file size must be between #{@storage_units[5120]}" \
                   " and #{@storage_units[10_240]}"
        )
      end

      it do
        is_expected.not_to allow_file_size(
          4.kilobytes, @validator,
          message: "Avatar file size must be between #{@storage_units[5120]}" \
                   " and #{@storage_units[10_240]}"
        )
      end
    end

    context 'given :greater_than and :less_than options' do
      before { build_validator greater_than: 5.kilobytes, less_than: 10.kilobytes }

      it do
        is_expected.not_to allow_file_size(
          11.kilobytes, @validator,
          message: "Avatar file size must be less than #{@storage_units[10_240]}"
        )
      end

      it do
        is_expected.not_to allow_file_size(
          4.kilobytes, @validator,
          message: "Avatar file size must be greater than #{@storage_units[5120]}"
        )
      end
    end

    context 'given :greater_than_or_equal_to and :less_than_or_equal_to options' do
      before do
        build_validator greater_than_or_equal_to: 5.kilobytes,
                        less_than_or_equal_to: 10.kilobytes
      end

      it do
        is_expected.not_to allow_file_size(
          11.kilobytes, @validator,
          message: "Avatar file size must be less than or equal to #{@storage_units[10_240]}"
        )
      end

      it do
        is_expected.not_to allow_file_size(
          4.kilobytes, @validator,
          message: "Avatar file size must be greater than or equal to #{@storage_units[5120]}"
        )
      end
    end
  end

  context 'exceptional file size' do
    before { build_validator less_than: 3.kilobytes }

    it { is_expected.to allow_file_size(0, @validator) } # zero-byte file
    it { is_expected.not_to allow_file_size(nil, @validator) }
  end

  context 'using the helper' do
    before { Dummy.validates_file_size :avatar, in: (5.kilobytes..10.kilobytes) }

    it 'adds the validator to the class' do
      expect(Dummy.validators_on(:avatar)).to include(described_class)
    end
  end

  context 'given options' do
    it 'raises argument error if no required argument was given' do
      expect { build_validator message: 'Some message' }.to raise_error(ArgumentError)
    end

    (described_class::CHECKS.keys - [:in]).each do |argument|
      it "does not raise argument error if :#{argument} is numeric or a proc" do
        expect { build_validator argument => 5.kilobytes }.not_to raise_error
        expect { build_validator argument => ->(_record) { 5.kilobytes } }.not_to raise_error
      end

      it "raises error if :#{argument} is neither a number nor a proc" do
        expect { build_validator argument => 5.kilobytes..10.kilobytes }.to raise_error(ArgumentError)
      end
    end

    it 'does not raise argument error if :in is a range or a proc' do
      expect { build_validator in: 5.kilobytes..10.kilobytes }.not_to raise_error
      expect { build_validator in: ->(_record) { 5.kilobytes..10.kilobytes } }.not_to raise_error
    end

    it 'raises error if :in is neither a range nor a proc' do
      expect { build_validator in: 5.kilobytes }.to raise_error(ArgumentError)
    end
  end
end
