# frozen_string_literal: true

require 'spec_helper'
require 'rack/test/uploaded_file'

describe 'File Content Type integration with ActiveModel' do
  class Person
    include ActiveModel::Validations
    attr_accessor :avatar
  end

  before :all do
    @cute_path = File.join(File.dirname(__FILE__), '../fixtures/cute.jpg')
    @chubby_bubble_path = File.join(File.dirname(__FILE__), '../fixtures/chubby_bubble.jpg')
    @chubby_cute_path = File.join(File.dirname(__FILE__), '../fixtures/chubby_cute.png')
    @sample_text_path = File.join(File.dirname(__FILE__), '../fixtures/sample.txt')
    @spoofed_file_path = File.join(File.dirname(__FILE__), '../fixtures/spoofed.jpg')
  end

  context ':allow option' do
    context 'a string' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: 'image/jpeg' }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
        it { is_expected.not_to be_valid }
      end
    end

    context 'as a regex' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: /^image\/.*/, mode: :strict }
        end
      end

      subject { Person.new }

      context 'with an allowed types' do
        it 'validates jpeg image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end

        it 'validates png image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png')
          expect(subject).to be_valid
        end
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain') }
        it { is_expected.not_to be_valid }
      end
    end

    context 'as a list' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: ['image/jpeg', 'text/plain'],
                                                  mode: :strict }
        end
      end

      subject { Person.new }

      context 'with allowed types' do
        it 'validates jpeg' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end

        it 'validates text file' do
          subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
          expect(subject).to be_valid
        end
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
        it { is_expected.not_to be_valid }
      end
    end

    context 'as a proc' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: ->(_record) { ['image/jpeg', 'text/plain'] },
                                                  mode: :strict }
        end
      end

      subject { Person.new }

      context 'with allowed types' do
        it 'validates jpeg' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end

        it 'validates text file' do
          subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
          expect(subject).to be_valid
        end
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
        it { is_expected.not_to be_valid }
      end
    end
  end

  context ':exclude option' do
    context 'a string' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { exclude: 'image/jpeg', mode: :strict }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
        it { is_expected.not_to be_valid }
      end
    end

    context 'as a regex' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { exclude: /^image\/.*/, mode: :strict }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed types' do
        it 'invalidates jpeg image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).not_to be_valid
        end

        it 'invalidates png image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png')
          expect(subject).not_to be_valid
        end
      end
    end

    context 'as a list' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { exclude: ['image/jpeg', 'text/plain'],
                                                  mode: :strict }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed types' do
        it 'invalidates jpeg' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).not_to be_valid
        end

        it 'invalidates text file' do
          subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
          expect(subject).not_to be_valid
        end
      end
    end

    context 'as a proc' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { exclude: ->(_record) { /^image\/.*/ },
                                                  mode: :strict }
        end
      end

      subject { Person.new }

      context 'with an allowed type' do
        before { subject.avatar = Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain') }
        it { is_expected.to be_valid }
      end

      context 'with a disallowed types' do
        it 'invalidates jpeg image file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).not_to be_valid
        end
      end
    end
  end

  context ':allow and :exclude combined' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_content_type: { allow: /^image\/.*/, exclude: 'image/png',
                                                mode: :strict }
      end
    end

    subject { Person.new }

    context 'with an allowed type' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
      it { is_expected.to be_valid }
    end

    context 'with a disallowed type' do
      before { subject.avatar = Rack::Test::UploadedFile.new(@chubby_cute_path, 'image/png') }
      it { is_expected.not_to be_valid }
    end
  end

  context ':tool option' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_content_type: { allow: 'image/jpeg', tool: :marcel }
      end
    end

    subject { Person.new }

    context 'with valid file' do
      it 'validates the file' do
        subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
        expect(subject).to be_valid
      end
    end

    context 'with spoofed file' do
      it 'invalidates the file' do
        subject.avatar = Rack::Test::UploadedFile.new(@spoofed_file_path, 'image/jpeg')
        expect(subject).not_to be_valid
      end
    end
  end

  context ':mode option' do
    context 'strict mode' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: 'image/jpeg', mode: :strict }
        end
      end

      subject { Person.new }

      context 'with valid file' do
        it 'validates the file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end
      end

      context 'with spoofed file' do
        it 'invalidates the file' do
          subject.avatar = Rack::Test::UploadedFile.new(@spoofed_file_path, 'image/jpeg')
          expect(subject).not_to be_valid
        end
      end
    end

    context 'relaxed mode' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: 'image/jpeg', mode: :relaxed }
        end
      end

      subject { Person.new }

      context 'with valid file' do
        it 'validates the file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end
      end

      context 'with spoofed file' do
        it 'validates the file' do
          subject.avatar = Rack::Test::UploadedFile.new(@spoofed_file_path, 'image/jpeg')
          expect(subject).to be_valid
        end
      end
    end

    context 'default mode' do
      before :all do
        Person.class_eval do
          Person.reset_callbacks(:validate)
          validates :avatar, file_content_type: { allow: 'image/jpeg' }
        end
      end

      subject { Person.new }

      context 'with valid file' do
        it 'validates the file' do
          subject.avatar = Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
          expect(subject).to be_valid
        end
      end

      context 'with spoofed file' do
        it 'invalidates the file' do
          subject.avatar = Rack::Test::UploadedFile.new(@spoofed_file_path, 'image/jpeg')
          expect(subject).to be_valid
        end
      end
    end
  end

  context 'image data as json string' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_content_type: { allow: 'image/jpeg' }
      end
    end

    subject { Person.new }

    context 'for invalid content type' do
      before do
        subject.avatar = '{"filename":"img140910_88338.GIF","content_type":"image/gif","size":13150}'
      end

      it { is_expected.not_to be_valid }
    end

    context 'for valid content type' do
      before do
        subject.avatar = '{"filename":"img140910_88338.jpg","content_type":"image/jpeg","size":13150}'
      end

      it { is_expected.to be_valid }
    end

    context 'empty json string' do
      before { subject.avatar = '{}' }
      it { is_expected.to be_valid }
    end

    context 'empty string' do
      before { subject.avatar = '' }
      it { is_expected.to be_valid }
    end

    context 'invalid json string' do
      before { subject.avatar = '{filename":"img140910_88338.jpg","content_type":"image/jpeg","size":13150}' }
      it { is_expected.not_to be_valid }
    end
  end

  context 'image data as hash' do
    before :all do
      Person.class_eval do
        Person.reset_callbacks(:validate)
        validates :avatar, file_content_type: { allow: 'image/jpeg' }
      end
    end

    subject { Person.new }

    context 'for invalid content type' do
      before do
        subject.avatar = {
          'filename' => 'img140910_88338.GIF',
          'content_type' => 'image/gif',
          'size' => 13_150
        }
      end

      it { is_expected.not_to be_valid }
    end

    context 'for valid content type' do
      before do
        subject.avatar = {
          'filename' => 'img140910_88338.jpg',
          'content_type' => 'image/jpeg',
          'size' => 13_150
        }
      end

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
        validates :avatar, file_content_type: { allow: 'image/jpeg' }
      end
    end

    subject { Person.new }

    context 'for one invalid content type' do
      before do
        subject.avatar = [
          Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain'),
          Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
        ]
      end
      it { is_expected.not_to be_valid }
    end

    context 'for two invalid content types' do
      before do
        subject.avatar = [
          Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain'),
          Rack::Test::UploadedFile.new(@sample_text_path, 'text/plain')
        ]
      end

      it 'is invalid and adds just one error' do
        expect(subject).not_to be_valid
        expect(subject.errors.count).to eq 1
      end
    end

    context 'for valid content type' do
      before do
        subject.avatar = [
          Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg'),
          Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg')
        ]
      end
      it { is_expected.to be_valid }
    end

    context 'empty array' do
      before { subject.avatar = [] }
      it { is_expected.to be_valid }
    end
  end
end
