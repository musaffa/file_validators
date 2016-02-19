module FileValidators
  module Utils

    class ContentTypeDetector
      # The content-type detection strategy is as follows:
      #
      # 1. Blank/Empty files: If there's no filepath or the file is empty,
      #    provide a sensible default (application/octet-stream or inode/x-empty)
      #
      # 2. Calculated match: Return the first result that is found by both the
      #    `file` command and MIME::Types.
      #
      # 3. Standard types: Return the first standard (without an x- prefix) entry
      #    in MIME::Types
      #
      # 4. Experimental types: If there were no standard types in MIME::Types
      #    list, try to return the first experimental one
      #
      # 5. Raw `file` command: Just use the output of the `file` command raw, or
      #    a sensible default. This is cached from Step 2.

      EMPTY_TYPE = "inode/x-empty"
      SENSIBLE_DEFAULT = "application/octet-stream"

      def initialize(filepath, content_type=nil)
        @filepath = filepath
        @content_type = content_type
      end

      # Returns a String describing the file's content type
      def detect
        if blank_name?
          SENSIBLE_DEFAULT
        elsif empty_file?
          EMPTY_TYPE
        elsif calculated_type_matches.any?
          calculated_type_matches.first
        else
          type_from_file_contents || SENSIBLE_DEFAULT
        end.to_s
      end

      # media type spoof detection strategy:
      #
      # 1. it will not identify as spoofed if file name doesn't have any extension
      # 2. it will identify as spoofed if any of the file extension's media types
      # matches the media type of the content type. So it will return true for
      # `text` of `text/plain` mismatch with `image` of `image/jpeg`, but return false
      # for `image` of `image/png` match with `image` of `image/jpeg`.

      def spoofed?
        has_extension? and media_type_mismatch?
      end

      private

      def has_extension?
        # the following code replaced File.extname(@file_name).present? because it cannot
        # return the extension of a extension-only file names, e.g. '.html', '.jpg' etc
        File.extname(@filepath).split('.').length > 1 || no_base_name_file_with_extension
      end

      def no_base_name_file_with_extension
        filepath_last = @filepath.split('/').last
        filepath_last.first == '.' && filepath_last.length > 1
      end

      def media_type_mismatch?
        possible_types.none? { |type| type.include? detected_media_type }
      end

      def detected_media_type
        @content_type.split('/').first || ''
      end

      def empty_file?
        File.exist?(@filepath) && File.size(@filepath) == 0
      end

      alias :empty? :empty_file?

      def blank_name?
        @filepath.nil? || @filepath.empty?
      end

      def file_exists?
        File.exist?(@filepath)
      end

      def calculated_type_matches
        possible_types.select do |content_type|
          content_type == type_from_file_contents
        end
      end

      def possible_types
        MIME::Types.type_for(@filepath).collect(&:content_type)
      end

      def type_from_file_contents
        type_from_mime_magic || type_from_file_command
      rescue Errno::ENOENT => e
        puts "Error while determining content type: #{e}"
        SENSIBLE_DEFAULT
      end

      def type_from_mime_magic
        @type_from_mime_magic ||=
          MimeMagic.by_magic(File.open(@filepath)).try(:type) if file_exists?
      end

      def type_from_file_command
        @type_from_file_command ||=
          FileCommandContentTypeDetector.new(@filepath).detect
      end
    end

  end
end
