module Types::Objects::Base
  class AttachmentType < Types::BaseObject
    field :id,          Int,      nil, null: false
    field :filename,    String,   nil, null: false
    field :url,         String,   nil, null: false
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

    def url
      if object.class.eql?(ActiveStorage::Variant)
        Rails.application.routes.url_helpers.rails_representation_url(object)
      elsif defined?(object.service_url)
        object.service_url
      else
        object.url
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
