require 'rails/generators'

module CmGraphql
  module Generators
    class AddGraphqlGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def add_graphql
        generate 'graphql:install'
        template 'graphql_schema.rb', "app/graphql/#{Rails.application.class.module_parent_name.underscore}_schema.rb"
        copy_file 'base_connection.rb', 'app/graphql/types/base_connection.rb'
        gsub_file 'app/controllers/graphql_controller.rb', '# protect_from_forgery with: :null_session', 'protect_from_forgery with: :null_session'
      end
    end
  end
end