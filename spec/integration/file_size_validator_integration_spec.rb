require 'spec_helper'
require 'rack/test/uploaded_file'

describe 'File Size Validator integration with ActiveModel' do
  class Person
    include ActiveModel::Validations
    attr_accessor :avatar
  end

  before :all do
    @cute_path = File.join(File.dirname(__FILE__), '../fixtures/cute.jpg')
    @chubby_bubble_path = File.join(File.dirname(__FILE__), '../fixtures/chubby_bubble.jpg')
    @chubby_cute_path = File.join(File.dirname(__FILE__), '../fixtures/chubby_cute.png')
  end

  context ':in option' do
    context 'as a range' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_size: { in: 20.kilobytes..40.kilobytes }
        end
      end

      subject { Person.new }

      context 'when file size is out of range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path) }
        it { is_expected.not_to be_valid }
      end

      context 'when file size is out of range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path) }
        it { is_expected.not_to be_valid }
      end

      context 'when file size within range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_bubble_path) }
        it { is_expected.to be_valid }
      end
    end

    context 'as a proc' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_size: { in: lambda { |record| 20.kilobytes..40.kilobytes } }
        end
      end

      subject { Person.new }

      context 'when file size is out of range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path) }
        it { is_expected.not_to be_valid }
      end

      context 'when file size is out of range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path) }
        it { is_expected.not_to be_valid }
      end

      context 'when file size within range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_bubble_path) }
        it { is_expected.to be_valid }
      end
    end
  end

  context ':greater_than and :less_than option' do
    context 'as numbers' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_size: { greater_than: 20.kilobytes,
                                          less_than:    40.kilobytes }
        end
      end

      subject { Person.new }

      context 'when file size is out of range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path) }
        it { is_expected.not_to be_valid }
      end

      context 'when file size is out of range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path) }
        it { is_expected.not_to be_valid }
      end

      context 'when file size within range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_bubble_path) }
        it { is_expected.to be_valid }
      end
    end

    context 'as procs' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_size: { greater_than: lambda { |record| 20.kilobytes },
                                          less_than:    lambda { |record| 40.kilobytes } }
        end
      end

      subject { Person.new }

      context 'when file size is out of range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path) }
        it { is_expected.not_to be_valid }
      end

      context 'when file size is out of range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path) }
        it { is_expected.not_to be_valid }
      end

      context 'when file size within range' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_bubble_path) }
        it { is_expected.to be_valid }
      end
    end
  end

  context ':less_than_or_equal_to option' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_size: { less_than_or_equal_to: 20.kilobytes }
      end
    end

    subject { Person.new }

    context 'when file size is greater than the specified size' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_bubble_path) }
      it { is_expected.not_to be_valid }
    end

    context 'when file size within the specified size' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path) }
      it { is_expected.to be_valid }
    end
  end

  context ':greater_than_or_equal_to option' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_size: { greater_than_or_equal_to: 20.kilobytes }
      end
    end

    subject { Person.new }

    context 'when file size is less than the specified size' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path) }
      it { is_expected.not_to be_valid }
    end

    context 'when file size within the specified size' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_bubble_path) }
      it { is_expected.to be_valid }
    end
  end

  context ':less_than option' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_size: { less_than: 20.kilobytes }
      end
    end

    subject { Person.new }

    context 'when file size is greater than the specified size' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_bubble_path) }
      it { is_expected.not_to be_valid }
    end

    context 'when file size within the specified size' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path) }
      it { is_expected.to be_valid }
    end
  end

  context ':greater_than option' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_size: { greater_than: 20.kilobytes }
      end
    end

    subject { Person.new }

    context 'when file size is less than the specified size' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path) }
      it { is_expected.not_to be_valid }
    end

    context 'when file size within the specified size' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_bubble_path) }
      it { is_expected.to be_valid }
    end
  end

  context 'image data as json string' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_size: { greater_than: 20.kilobytes }
      end
    end

    subject { Person.new }

    context 'when file size is less than the specified size' do
      before { subject.avatar = "{\"filename\":\"img140910_88338.GIF\",\"content_type\":\"image/gif\",\"size\":13150}" }
      it { is_expected.not_to be_valid }
    end

    context 'when file size within the specified size' do
      before { subject.avatar = "{\"filename\":\"img140910_88338.GIF\",\"content_type\":\"image/gif\",\"size\":33150}" }
      it { is_expected.to be_valid }
    end

    context 'empty json string' do
      before { subject.avatar = "{}" }
      it { is_expected.to be_valid }
    end

    context 'empty json string' do
      before { subject.avatar = "" }
      it { is_expected.to be_valid }
    end
  end

  context 'image data as hash' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_size: { greater_than: 20.kilobytes }
      end
    end

    subject { Person.new }

    context 'when file size is less than the specified size' do
      before { subject.avatar = { "filename" => "img140910_88338.GIF", "content_type" => "image/gif", "size" => 13150 } }
      it { is_expected.not_to be_valid }
    end

    context 'when file size within the specified size' do
      before { subject.avatar = { "filename" => "img140910_88338.GIF", "content_type" => "image/gif", "size" => 33150 } }
      it { is_expected.to be_valid }
    end

    context 'empty hash' do
      before { subject.avatar = {} }
      it { is_expected.to be_valid }
    end
  end

  context 'image data as array' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_size: { greater_than: 20.kilobytes }
      end
    end

    subject { Person.new }

    context 'when size of one file is less than the specified size' do
      before {
        subject.avatar = [
          Rack::Test::UploadedFile.new(@cute_path),
          Rack::Test::UploadedFile.new(@chubby_bubble_path)
        ]
      }
      it { is_expected.not_to be_valid }
    end

    context 'when size of all files is within the specified size' do
      before {
        subject.avatar = [
          Rack::Test::UploadedFile.new(@cute_path),
          Rack::Test::UploadedFile.new(@cute_path)
        ]
      }

      it 'is invalid and adds just one error' do
        expect(subject).not_to be_valid
        expect(subject.errors.count).to eq 1
      end
    end

    context 'when size of all files is less than the specified size' do
      before {
        subject.avatar = [
          Rack::Test::UploadedFile.new(@chubby_bubble_path),
          Rack::Test::UploadedFile.new(@chubby_bubble_path)
        ]
      }

      it { is_expected.to be_valid }
    end

    context 'one file' do
      context 'when file size is out of range' do
        before { subject.avatar = [Rack::Test::UploadedFile.new(@cute_path)] }
        it { is_expected.not_to be_valid }
      end

      context 'when file size within range' do
        before { subject.avatar = [Rack::Test::UploadedFile.new(@chubby_bubble_path)] }
        it { is_expected.to be_valid }
      end
    end

    context 'empty array' do
      before { subject.avatar = [] }
      it { is_expected.to be_valid }
    end
  end
end
