module Types
  module Inputs
    class ImageResolution < Base::Filter
      graphql_name 'ImageResolution'

      description 'Additional attributes needed for Image Resolution'

      argument :width,         Integer,  nil,  required: true
      argument :height,        Integer,  nil,  required: true
    end
  end
end