require 'spec_helper'
require 'tempfile'

describe FileValidators::Utils::ContentTypeDetector do
  it 'returns the empty content type when the file is empty' do
    tempfile = Tempfile.new('empty')
    expect(described_class.new(tempfile.path, tempfile.path).detect).to eql('inode/x-empty')
    tempfile.close
  end

  it 'returns a content type based on the content of the file' do
    tempfile = Tempfile.new('something')
    tempfile.write('This is a file.')
    tempfile.rewind
    expect(described_class.new(tempfile.path, tempfile.path).detect).to eql('text/plain')
    tempfile.close
  end

  it 'returns a sensible default when the file path is empty' do
    expect(described_class.new('', '').detect).to eql('application/octet-stream')
  end

  it 'returns a sensible default if the file path is invalid' do
    file_path = '/path/to/nothing'
    expect(described_class.new(file_path, file_path).detect).to eql('application/octet-stream')
  end
end
