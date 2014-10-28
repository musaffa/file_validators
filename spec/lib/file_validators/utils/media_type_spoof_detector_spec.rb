require 'spec_helper'

describe FileValidators::Utils::MediaTypeSpoofDetector do
  it 'rejects a file with an extension .html and identifies as jpeg' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('image/jpeg', 'sample.html')).to be_spoofed
  end

  it 'does not reject a file with an extension .jpg and identifies as png' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('image/png', 'sample.jpg')).not_to be_spoofed
  end

  it 'does not reject a file with an extension .txt and identifies as text' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('text/plain', 'sample.txt')).not_to be_spoofed
  end

  it 'does not reject a file that does not have any name' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('text/plain', '')).not_to be_spoofed
  end

  it 'does not reject a file that does not have any extension' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('text/plain', 'sample')).not_to be_spoofed
  end

  it 'rejects a file that does not have a basename but has an extension with mismatched media type' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('image/jpeg', '.html')).to be_spoofed
  end

  it 'does not reject a file that does not have a basename but has an extension with valid media type' do
    expect(FileValidators::Utils::MediaTypeSpoofDetector.new('image/png', '.jpg')).not_to be_spoofed
  end
end
