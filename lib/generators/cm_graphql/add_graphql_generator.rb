require 'rails/generators'

module CmGraphql
  module Generators
    class AddGraphqlGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_graphql
        generate 'graphql:install'
        template 'graphql_schema.rb', "app/graphql/#{Rails.application.class.module_parent_name.underscore}_schema.rb"
      end
    end
  end
end