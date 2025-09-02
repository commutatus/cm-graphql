module Types
  module EnumHelpers
    def self.enum_from_model(model, enum_name, graphql_enum_name: nil)
      enum_values = model.send(enum_name.to_s.pluralize).keys

      graphql_class_name = graphql_enum_name || "#{model.name}#{enum_name.to_s.camelize}Enum"

      return const_get(graphql_class_name) if const_defined?(graphql_class_name)

      Object.const_set(graphql_class_name, Class.new(Types::BaseEnum) do
        graphql_name(graphql_class_name)

        enum_values.each do |val|
          value val, description: "#{val.titleize} #{enum_name}"
        end
      end)
    end

    def self.enum_from_array(array, graphql_enum_name)
      enum_values = array.map(&:to_s)

      return const_get(graphql_enum_name) if const_defined?(graphql_enum_name)

      Object.const_set(graphql_enum_name, Class.new(Types::BaseEnum) do
        graphql_name(graphql_enum_name)

        enum_values.each do |val|
          value val, description: val.titleize
        end
      end)
    end
  end
end
