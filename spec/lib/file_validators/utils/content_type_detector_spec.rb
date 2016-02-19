require 'spec_helper'
require 'tempfile'

describe FileValidators::Utils::ContentTypeDetector do
  describe '#detect' do
    it 'returns the empty content type when the file is empty' do
      tempfile = Tempfile.new('empty')
      expect(FileValidators::Utils::ContentTypeDetector.new(tempfile.path).detect).to eql('inode/x-empty')
      tempfile.close
    end

    it 'returns a content type based on the content of the file' do
      tempfile = Tempfile.new('something')
      tempfile.write('This is a file.')
      tempfile.rewind
      expect(FileValidators::Utils::ContentTypeDetector.new(tempfile.path).detect).to eql('text/plain')
      tempfile.close
    end

    it 'returns a sensible default when the file path is empty' do
      expect(FileValidators::Utils::ContentTypeDetector.new('').detect).to eql('application/octet-stream')
    end

    it 'returns a sensible default if the file path is invalid' do
      @filename = '/path/to/nothing'
      expect(FileValidators::Utils::ContentTypeDetector.new(@filename).detect).to eql('application/octet-stream')
    end
  end

  describe '#spoofed?' do
    it 'rejects a file with an extension .html and identifies as jpeg' do
      path = File.join(File.dirname(__FILE__), '../fixtures/cute.html')
      expect(FileValidators::Utils::ContentTypeDetector.new(path, 'image/jpeg')).to be_spoofed
    end

    it 'does not reject a file with an extension .jpg and identifies as png' do
      path = File.join(File.dirname(__FILE__), '../fixtures/cute.png')
      expect(FileValidators::Utils::ContentTypeDetector.new(path, 'image/png')).not_to be_spoofed
    end

    it 'does not reject a file with an extension .txt and identifies as text' do
      path = File.join(File.dirname(__FILE__), '../fixtures/sample.txt')
      expect(FileValidators::Utils::ContentTypeDetector.new(path,'text/plain')).not_to be_spoofed
    end

    it 'does not reject a file that does not have any name' do
      path = File.join(File.dirname(__FILE__), '../fixtures/cute.jpg')
      expect(FileValidators::Utils::ContentTypeDetector.new(path, '')).not_to be_spoofed
    end

    it 'does not reject a file that does not have any extension' do
      path = File.join(File.dirname(__FILE__), '../fixtures/cute')
      expect(FileValidators::Utils::ContentTypeDetector.new(path, 'text/plain')).not_to be_spoofed
    end

    it 'rejects a file that does not have a basename but has an extension with mismatched media type' do
      path = File.join(File.dirname(__FILE__), '../fixtures/.html')
      expect(FileValidators::Utils::ContentTypeDetector.new(path, 'image/jpeg')).to be_spoofed
    end

    it 'does not reject a file that does not have a basename but has an extension with valid media type' do
      path = File.join(File.dirname(__FILE__), '../fixtures/.jpg')
      expect(FileValidators::Utils::ContentTypeDetector.new(path, 'image/png')).not_to be_spoofed
    end
  end
end
