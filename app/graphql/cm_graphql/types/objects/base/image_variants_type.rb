# frozen_string_literal: true

module CmGraphql
  module Types
    module Objects
      module Base
        class ImageVariantsType < ::Types::BaseObject
          description 'Named image variant URLs for an attached image.'

          CmGraphql::AttachmentVariantsService::DEFAULT_VARIANTS.each_key do |variant_name|
            field_name = variant_name.downcase

            field field_name, String, null: true,
                    description: "#{variant_name} image variant URL."

            define_method(field_name) do
              CmGraphql::AttachmentVariantsService.url_for(object, variant_name)
            end
          end
        end
      end
    end
  end
end
