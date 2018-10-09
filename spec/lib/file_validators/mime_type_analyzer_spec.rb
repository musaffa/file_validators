# frozen_string_literal: true

require 'spec_helper'
require 'rack/test/uploaded_file'

describe FileValidators::MimeTypeAnalyzer do
  it 'rises error when tool is invalid' do
    expect { described_class.new(:invalid) }.to raise_error(FileValidators::Error)
  end

  before :all do
    @cute_path = File.join(File.dirname(__FILE__), '../../fixtures/cute.jpg')
    @spoofed_file_path = File.join(File.dirname(__FILE__), '../../fixtures/spoofed.jpg')
  end

  let(:cute_image) { Rack::Test::UploadedFile.new(@cute_path, 'image/jpeg') }
  let(:spoofed_file) { Rack::Test::UploadedFile.new(@spoofed_file_path, 'image/jpeg') }

  describe ':file analyzer' do
    let(:analyzer) { described_class.new(:file) }

    it 'determines MIME type from file contents' do
      expect(analyzer.call(cute_image)).to eq('image/jpeg')
    end

    it 'returns text/plain for unidentified MIME types' do
      expect(analyzer.call(fakeio('a' * 5 * 1024 * 1024))).to eq('text/plain')
    end

    it 'is able to determine MIME type for spoofed files' do
      expect(analyzer.call(spoofed_file)).to eq('text/plain')
    end

    it 'is able to determine MIME type for non-files' do
      expect(analyzer.call(fakeio(cute_image.read))).to eq('image/jpeg')
    end

    it 'returns nil for empty IOs' do
      expect(analyzer.call(fakeio(''))).to eq(nil)
    end

    it 'raises error if file command is not found' do
      allow(Open3).to receive(:popen3).and_raise(Errno::ENOENT)
      expect { analyzer.call(fakeio) }.to raise_error(FileValidators::Error, 'file command-line tool is not installed')
    end
  end

  describe ':fastimage analyzer' do
    let(:analyzer) { described_class.new(:fastimage) }

    it 'extracts MIME type of any IO' do
      expect(analyzer.call(cute_image)).to eq('image/jpeg')
    end

    it 'returns nil for unidentified MIME types' do
      expect(analyzer.call(fakeio('😃'))).to eq nil
    end

    it 'returns nil for empty IOs' do
      expect(analyzer.call(fakeio(''))).to eq nil
    end
  end

  describe ':mimemagic analyzer' do
    let(:analyzer) { described_class.new(:mimemagic) }

    it 'extracts MIME type of any IO' do
      expect(analyzer.call(cute_image)).to eq('image/jpeg')
    end

    it 'returns nil for unidentified MIME types' do
      expect(analyzer.call(fakeio('😃'))).to eq nil
    end

    it 'returns nil for empty IOs' do
      expect(analyzer.call(fakeio(''))).to eq nil
    end
  end

  if RUBY_VERSION >= '2.2.0'
    describe ':marcel analyzer' do
      let(:analyzer) { described_class.new(:marcel) }

      it 'extracts MIME type of any IO' do
        expect(analyzer.call(cute_image)).to eq('image/jpeg')
      end

      it 'returns application/octet-stream for unidentified MIME types' do
        expect(analyzer.call(fakeio('😃'))).to eq 'application/octet-stream'
      end

      it 'returns nil for empty IOs' do
        expect(analyzer.call(fakeio(''))).to eq nil
      end
    end
  end

  describe ':mime_types analyzer' do
    let(:analyzer) { described_class.new(:mime_types) }

    it 'extract MIME type from the file extension' do
      expect(analyzer.call(fakeio(filename: 'image.png'))).to eq('image/png')
      expect(analyzer.call(cute_image)).to eq('image/jpeg')
    end

    it 'extracts MIME type from file extension when IO is empty' do
      expect(analyzer.call(fakeio('', filename: 'image.png'))).to eq('image/png')
    end

    it 'returns nil on unknown extension' do
      expect(analyzer.call(fakeio(filename: 'file.foo'))).to eq(nil)
    end

    it 'returns nil when input is not a file' do
      expect(analyzer.call(fakeio)).to eq(nil)
    end
  end

  describe ':mini_mime analyzer' do
    let(:analyzer) { described_class.new(:mini_mime) }

    it 'extract MIME type from the file extension' do
      expect(analyzer.call(fakeio(filename: 'image.png'))).to eq('image/png')
      expect(analyzer.call(cute_image)).to eq('image/jpeg')
    end

    it 'extracts MIME type from file extension when IO is empty' do
      expect(analyzer.call(fakeio('', filename: 'image.png'))).to eq('image/png')
    end

    it 'returns nil on unkown extension' do
      expect(analyzer.call(fakeio(filename: 'file.foo'))).to eq(nil)
    end

    it 'returns nil when input is not a file' do
      expect(analyzer.call(fakeio)).to eq(nil)
    end
  end
end
