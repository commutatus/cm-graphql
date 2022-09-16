require 'rails/generators'

module CmGraphql
  module Generators
    class ListApiGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_graphql
        @model_name = args.first
        template "list_type.rb", "app/graphql/types/objects/#{@model_name}_list_type.rb"
        template "record_type.rb", "app/graphql/types/objects/#{@model_name}_type.rb"
        template "query_type.rb", "app/graphql/queries/#{@model_name}.rb"
      end
    end
  end
end