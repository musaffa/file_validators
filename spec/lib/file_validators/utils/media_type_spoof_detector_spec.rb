require 'spec_helper'

describe FileValidators::Utils::MediaTypeSpoofDetector do
  it 'rejects a file that is named .html and identifies as jpeg' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('image/jpeg', 'sample.html')).to be_spoofed
  end

  it 'does not reject a file that is named .jpg and identifies as png' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('image/png', 'sample.jpg')).not_to be_spoofed
  end

  it 'does not reject a file that is named .txt and identifies as text' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('text/plain', 'sample.txt')).not_to be_spoofed
  end

  it 'does not reject a file that does not have a name' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('text/plain', '')).not_to be_spoofed
  end

  it 'does not reject a file that does have an extension' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('text/plain', 'sample')).not_to be_spoofed
  end
end
