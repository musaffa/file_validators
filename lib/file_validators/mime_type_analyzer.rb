# frozen_string_literal: true

# Extracted from shrine/plugins/determine_mime_type.rb
module FileValidators
  class MimeTypeAnalyzer
    SUPPORTED_TOOLS = %i[fastimage file filemagic mimemagic marcel mime_types mini_mime].freeze
    MAGIC_NUMBER    = 256 * 1024

    def initialize(tool)
      raise Error, "unknown mime type analyzer #{tool.inspect}, supported analyzers are: #{SUPPORTED_TOOLS.join(',')}" unless SUPPORTED_TOOLS.include?(tool)

      @tool = tool
    end

    def call(io)
      mime_type = send(:"extract_with_#{@tool}", io)
      io.rewind

      mime_type
    end

    private

    def extract_with_file(io)
      require 'open3'

      return nil if io.eof? # file command returns "application/x-empty" for empty files

      Open3.popen3(*%W[file --mime-type --brief -]) do |stdin, stdout, stderr, thread|
        begin
          IO.copy_stream(io, stdin.binmode)
        rescue Errno::EPIPE
        end
        stdin.close

        status = thread.value

        raise Error, "file command failed to spawn: #{stderr.read}" if status.nil?
        raise Error, "file command failed: #{stderr.read}" unless status.success?
        $stderr.print(stderr.read)

        stdout.read.strip
      end
    rescue Errno::ENOENT
      raise Error, 'file command-line tool is not installed'
    end

    def extract_with_fastimage(io)
      require 'fastimage'

      type = FastImage.type(io)
      "image/#{type}" if type
    end

    def extract_with_filemagic(io)
      require 'filemagic'

      return nil if io.eof? # FileMagic returns "application/x-empty" for empty files

      FileMagic.open(FileMagic::MAGIC_MIME_TYPE) do |filemagic|
        filemagic.buffer(io.read(MAGIC_NUMBER))
      end
    end

    def extract_with_mimemagic(io)
      require 'mimemagic'

      mime = MimeMagic.by_magic(io)
      mime.type if mime
    end

    def extract_with_marcel(io)
      require 'marcel'

      return nil if io.eof? # marcel returns "application/octet-stream" for empty files

      Marcel::MimeType.for(io)
    end

    def extract_with_mime_types(io)
      require 'mime/types'

      if filename = extract_filename(io)
        mime_type = MIME::Types.of(filename).first
        mime_type.content_type if mime_type
      end
    end

    def extract_with_mini_mime(io)
      require 'mini_mime'

      if filename = extract_filename(io)
        info = MiniMime.lookup_by_filename(filename)
        info.content_type if info
      end
    end

    def extract_filename(io)
      if io.respond_to?(:original_filename)
        io.original_filename
      elsif io.respond_to?(:path)
        File.basename(io.path)
      end
    end
  end
end
