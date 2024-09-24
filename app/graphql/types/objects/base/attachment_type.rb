module Types::Objects::Base
  class AttachmentType < Types::BaseObject
    field :id,          Int,      nil, null: false
    field :filename,    String,   nil, null: false
    field :url,         String,   nil, null: false do
      argument :resolution, Types::Inputs::ImageResolution, required: false, default_value: nil
    end
    field :base64,      String,   nil, null: false

    def id
      if object.class.eql?(ActiveStorage::Variant)
        object.blob.id
      else
        object.id
      end
    end

    def filename
      if object.class.eql?(ActiveStorage::Variant)
        object.blob.filename.to_s + "-" + object.variation.transformations[:resize]
      else
        object.filename.to_s
      end
    end

    def url(resolution:)
      resized_image = resize_image(resolution&.width, resolution&.height, object)
      if resized_image.class.eql?(ActiveStorage::Variant) || resized_image.class.eql?(ActiveStorage::VariantWithRecord)
        Rails.application.routes.url_helpers.rails_representation_url(resized_image)
      elsif defined?(resized_image.service_url)
        resized_image.service_url
      else
        resized_image.url
      end
    end

    def resize_image(width, height, attachment)
      if width.present? && height.present? && attachment.attached?
        attachment.variant(resize_to_fill: [width, height])
      else
        attachment
      end
    end

    def base64
      data = if object.class.eql?(ActiveStorage::Variant)
               Base64.strict_encode64(object.blob.download)
             else
               Base64.strict_encode64(object.download)
             end
      "data:#{object.content_type};base64,#{data}"
    end
  end
end
