module Types
  module EnumHelpers
    def self.enum_from_model(model, enum_name, graphql_enum_name: nil)
      enum_values = model.send(enum_name.to_s.pluralize).keys

      Class.new(Types::BaseEnum) do
        graphql_name(graphql_enum_name || "#{model.name}#{enum_name.to_s.camelize}Enum")

        enum_values.each do |val|
          value val, description: "#{val.titleize} #{enum_name}"
        end
      end
    end

    def self.enum_from_array(array, graphql_enum_name)
      enum_values = array.map(&:to_s)

      Class.new(Types::BaseEnum) do
        graphql_name(graphql_enum_name)

        enum_values.each do |val|
          value val, description: val.titleize
        end
      end
    end
  end
end
