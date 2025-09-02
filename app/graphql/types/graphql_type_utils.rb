module Types
  module GraphqlTypeUtils
    def self.get_or_check_existing_constant(graphql_class_name)
      const_get(graphql_class_name) if const_defined?(graphql_class_name)
    end
  end
end
