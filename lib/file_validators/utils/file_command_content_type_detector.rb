begin
  require 'cocaine'
rescue LoadError
end

module FileValidators
  module Utils

    class FileCommandContentTypeDetector
      SENSIBLE_DEFAULT = "application/octet-stream"

      def initialize(filename)
        @filename = filename
      end

      def detect
        type_from_file_command
      end

      private

      def type_from_file_command
        # On BSDs, `file` doesn't give a result code of 1 if the file doesn't exist.
        type = begin
          Cocaine::CommandLine.new('file', '-b --mime-type :file').run(file: @filename)
        rescue Cocaine::CommandLineError => e
          puts "file_validators: Add 'cocaine' gem as you are using file content type validations in strict mode"
          SENSIBLE_DEFAULT
        end

        if type.nil? || type.match(/\(.*?\)/)
          type = SENSIBLE_DEFAULT
        end
        type.split(/[:;\s]+/)[0]
      end
    end
  end
end
