# frozen_string_literal: true

module CmGraphql
  class AttachmentVariantsService
    DEFAULT_VARIANTS = {
      'AVATAR_96' => { resize_to_fill: [96, 96] },
      'AVATAR_256' => { resize_to_fill: [256, 256] },
      'GALLERY_512' => { resize_to_fill: [512, 512] },
      'FULL_1080' => { resize_to_limit: [1080, 1080] }
    }.freeze

    def self.image?(attachment)
      return false if attachment.blank?
      return false if attachment.respond_to?(:attached?) && !attachment.attached?

      content_type = if attachment.respond_to?(:content_type)
                       attachment.content_type
                     elsif attachment.respond_to?(:blob)
                       attachment.blob.content_type
                     end
      content_type.to_s.start_with?('image/')
    end

    def self.url_for(attachment, variant_name)
      transformations = DEFAULT_VARIANTS[variant_name.to_s]
      return nil if transformations.blank?

      Rails.application.routes.url_helpers.rails_representation_url(
        attachment.variant(transformations)
      )
    end
  end
end
