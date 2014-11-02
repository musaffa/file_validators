require 'mime/types'

module FileValidators
  module Utils

    class MediaTypeSpoofDetector
      def initialize(content_type, file_name)
        @content_type = content_type
        @file_name = file_name
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
        @file_name.split('.').length > 1
      end

      def media_type_mismatch?
        supplied_media_types.none? { |type| type == detected_media_type }
      end

      def supplied_media_types
        MIME::Types.type_for(@file_name).collect(&:media_type)
      end

      def detected_media_type
        @content_type.split('/').first
      end
    end

  end
end
