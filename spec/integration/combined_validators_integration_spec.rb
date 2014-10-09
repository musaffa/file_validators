require 'spec_helper'
require 'rack/test/uploaded_file'

describe 'Combined File Validators integration with ActiveModel' do
  class Person
    include ActiveModel::Validations
    attr_accessor :avatar
  end

  before :all do
    @cute_path = File.join(File.dirname(__FILE__), '../fixtures/cute.jpg')
    @chubby_bubble_path = File.join(File.dirname(__FILE__), '../fixtures/chubby_bubble.jpg')
    @chubby_cute_path = File.join(File.dirname(__FILE__), '../fixtures/chubby_cute.png')
    @sample_text_path = File.join(File.dirname(__FILE__), '../fixtures/sample.txt')
  end

  context 'without helpers' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_size: { less_than: 20.kilobytes },
                           file_content_type: { in: 'image/jpeg' }
      end
    end

    subject { Person.new }

    context 'with an allowed type' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
      it { is_expected.to be_valid }
    end

    context 'with a disallowed type' do
      it 'invalidates png image file' do
        subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png')
        expect(subject).not_to be_valid
      end

      it 'invalidates text file' do
        subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
        expect(subject).not_to be_valid
      end
    end
  end

  context 'with helpers' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates_file_size :avatar, { less_than: 20.kilobytes }
        validates_file_content_type :avatar, in: 'image/jpeg'
      end
    end

    subject { Person.new }

    context 'with an allowed type' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
      it { is_expected.to be_valid }
    end

    context 'with a disallowed type' do
      it 'invalidates png image file' do
        subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png')
        expect(subject).not_to be_valid
      end

      it 'invalidates text file' do
        subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
        expect(subject).not_to be_valid
      end
    end
  end
end
