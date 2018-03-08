require 'logger'

begin
  require 'filemagic'
rescue LoadError
  puts "file_validators requires 'filemagic' gem as you are using file content type validations in strict mode"
end

module FileValidators
  module Utils

    class ContentTypeDetector
      EMPTY_CONTENT_TYPE = 'inode/x-empty'
      DEFAULT_CONTENT_TYPE = 'application/octet-stream'

      attr_accessor :file_path, :file_name

      def initialize(file_path, file_name)
        @file_path = file_path
        @file_name = file_name
      end

      # content type detection strategy:
      #
      # 1. invalid file_path: returns 'application/octet-stream'
      # 2. empty file: returns 'inode/x-empty'
      # 3. valid file: returns the content type using file command
      # 4. valid file but file commoand raises error: returns 'application/octet-stream'

      def detect
        if !File.exist?(file_path)
          DEFAULT_CONTENT_TYPE
        elsif File.zero?(file_path)
          EMPTY_CONTENT_TYPE
        else
          content_type_from_content
        end
      end

      private

      def content_type_from_content
        content_type = type_from_file_command

        if FileValidators::Utils::MediaTypeSpoofDetector.new(content_type, file_name).spoofed?
          logger.warn('A file with a spoofed media type has been detected by the file validators.')
        else
          content_type
        end
      end

      def type_from_file_command
        FileMagic.open(:mime) do |fm|
          fm.flags = [:mime_type]
          fm.file @file_path
        end
      end

      def logger
        Logger.new(STDOUT)
      end
    end

  end
end
