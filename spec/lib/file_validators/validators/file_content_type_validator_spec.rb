require 'spec_helper'

describe ActiveModel::Validations::FileContentTypeValidator do
  class Dummy
    include ActiveModel::Validations
  end

  subject { Dummy }

  def build_validator(options)
    @validator = described_class.new(options.merge(attributes: :avatar))
  end

  context 'whitelist format' do
    context 'with an allowed type' do
      context 'as a string' do
        before { build_validator allow: 'image/jpg' }
        it { is_expected.to allow_file_content_type('image/jpg', @validator) }
      end
  
      context 'as an regexp' do
        before { build_validator allow: /^image\/.*/ }
        it { is_expected.to allow_file_content_type('image/png', @validator) }
      end
  
      context 'as a list' do
        before { build_validator allow: ['image/png', 'image/jpg', 'image/jpeg'] }
        it { is_expected.to allow_file_content_type('image/png', @validator) }
      end

      context 'as a proc' do
        before { build_validator allow: lambda { |record| ['image/png', 'image/jpg', 'image/jpeg'] } }
        it { is_expected.to allow_file_content_type('image/png', @validator) }
      end
    end
  
    context 'with a disallowed type' do
      context 'as a string' do
        before { build_validator allow: 'image/png' }
        it { is_expected.not_to allow_file_content_type('image/jpeg', @validator) }
      end
  
      context 'as a regexp' do
        before { build_validator allow: /^text\/.*/ }
        it { is_expected.not_to allow_file_content_type('image/png', @validator) }
      end

      context 'as a proc' do
        before { build_validator allow: lambda { |record| /^text\/.*/ } }
        it { is_expected.not_to allow_file_content_type('image/png', @validator) }
      end
  
      context 'with :message option' do
        context 'without interpolation' do
          before { build_validator allow: 'image/png', message: 'should be a PNG image' }
          it { is_expected.not_to allow_file_content_type('image/jpeg', @validator, message: 'Avatar should be a PNG image') }
        end
  
        context 'with interpolation' do
          before { build_validator allow: 'image/png', message: 'should have content type %{types}' }
          it { is_expected.not_to allow_file_content_type('image/jpeg', @validator,
                                                          message: 'Avatar should have content type image/png') }
          it { is_expected.to allow_file_content_type('image/png', @validator,
                                                          message: 'Avatar should have content type image/png') }
        end
      end

      context 'default message' do
        before { build_validator allow: 'image/png' }
        it { is_expected.not_to allow_file_content_type('image/jpeg', @validator, message: 'Avatar file should be one of image/png') }
      end
    end
  end

  context 'blacklist format' do
    context 'with an allowed type' do
      context 'as a string' do
        before { build_validator exclude: 'image/gif' }
        it { is_expected.to allow_file_content_type('image/png', @validator) }
      end
  
      context 'as an regexp' do
        before { build_validator exclude: /^text\/.*/ }
        it { is_expected.to allow_file_content_type('image/png', @validator) }
      end
  
      context 'as a list' do
        before { build_validator exclude: ['image/png', 'image/jpg', 'image/jpeg'] }
        it { is_expected.to allow_file_content_type('image/gif', @validator) }
      end

      context 'as a proc' do
        before { build_validator exclude: lambda { |record| ['image/png', 'image/jpg', 'image/jpeg'] } }
        it { is_expected.to allow_file_content_type('image/gif', @validator) }
      end
    end
  
    context 'with a disallowed type' do
      context 'as a string' do
        before { build_validator exclude: 'image/gif' }
        it { is_expected.not_to allow_file_content_type('image/gif', @validator) }
      end

      context 'as an regexp' do
        before { build_validator exclude: /^text\/.*/ }
        it { is_expected.not_to allow_file_content_type('text/plain', @validator) }
      end

      context 'as an proc' do
        before { build_validator exclude: lambda { |record| /^text\/.*/ } }
        it { is_expected.not_to allow_file_content_type('text/plain', @validator) }
      end
  
      context 'with :message option' do
        context 'without interpolation' do
          before { build_validator exclude: 'image/png', message: 'should not be a PNG image' }
          it { is_expected.not_to allow_file_content_type('image/png', @validator, message: 'Avatar should not be a PNG image') }
        end
  
        context 'with interpolation' do
          before { build_validator exclude: 'image/png', message: 'should not have content type %{types}' }
          it { is_expected.not_to allow_file_content_type('image/png', @validator,
                                                          message: 'Avatar should not have content type image/png') }
          it { is_expected.to allow_file_content_type('image/jpeg', @validator,
                                                      message: 'Avatar should not have content type image/jpeg') }
        end
      end

      context 'default message' do
        before { build_validator exclude: 'image/png' }
        it { is_expected.not_to allow_file_content_type('image/png', @validator, message: 'Avatar file cannot be image/png') }
      end
    end
  end

  context 'using the helper' do
    before { Dummy.validates_file_content_type :avatar, allow: 'image/jpg' }

    it 'adds the validator to the class' do
      expect(Dummy.validators_on(:avatar)).to include(described_class)
    end
  end

  context 'given options' do
    it 'raises argument error if no required argument was given' do
      expect { build_validator message: 'Some message' }.to raise_error(ArgumentError)
    end

    described_class::CHECKS.each do |argument|
      it "does not raise error if :#{argument} is string, array, regexp or a proc" do
        expect { build_validator argument => 'image/jpg' }.not_to raise_error
        expect { build_validator argument => ['image/jpg'] }.not_to raise_error
        expect { build_validator argument => /^image\/.*/ }.not_to raise_error
        expect { build_validator argument => lambda { |record| 'image/jpg' } }.not_to raise_error
      end

      it "raises argument error if :#{argument} is neither a string, array, regexp nor proc" do
        expect { build_validator argument => 5.kilobytes }.to raise_error(ArgumentError)
      end
    end
  end
end
