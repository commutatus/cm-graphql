module Types
  module EnumHelpers
    def self.enum_from_model(model, enum_name, graphql_enum_name: nil)
      graphql_class_name = graphql_enum_name || "#{model.name}#{enum_name.to_s.camelize}Enum"

      existing_enum = Types::GraphqlTypeUtils.get_or_check_existing_constant(graphql_class_name)
      return existing_enum if existing_enum

      enum_values = model.send(enum_name.to_s.pluralize).keys
      Object.const_set(graphql_class_name, Class.new(Types::BaseEnum) do
        graphql_name(graphql_class_name)

        enum_values.each do |val|
          value val, description: "#{val.titleize} #{enum_name}"
        end
      end)
    end

    def self.enum_from_array(array, graphql_enum_name)
      enum_values = array.map(&:to_s)

      existing_enum = Types::GraphqlTypeUtils.get_or_check_existing_constant(graphql_enum_name)
      return existing_enum if existing_enum

      Object.const_set(graphql_enum_name, Class.new(Types::BaseEnum) do
        graphql_name(graphql_enum_name)

        enum_values.each do |val|
          value val, description: val.titleize
        end
      end)
    end
  end
end
