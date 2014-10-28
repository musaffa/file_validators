require 'mime/types'

module FileValidators
  module Utils

    class MediaTypeSpoofDetector
      def initialize(content_type, file_name)
        @content_type = content_type
        @file_name = file_name
      end

      def spoofed?
        has_extension? and media_type_mismatch?
      end

      private

      def has_extension?
        File.extname(@file_name).present?
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
