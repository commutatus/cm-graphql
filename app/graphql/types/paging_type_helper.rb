module Types
  module PagingTypeHelper
    def self.paging_type_for_model(model:, record_data_type: nil, graphql_type_name: nil)
      graphql_class_name = graphql_type_name.presence || "#{model}PagingType"

      existing_paging_type = Types::GraphqlTypeUtils.get_or_check_existing_constant(graphql_class_name)
      return existing_paging_type if existing_paging_type

      Object.const_set(graphql_class_name, Class.new(Types::BaseObject) do
        graphql_name(graphql_class_name)

        model_data_type = if record_data_type.present?
                            record_data_type.to_s.constantize
                          else
                            "Types::Objects::#{model}Type".constantize
                          end

        field :paging, Types::Objects::Base::PagingType, null: true
        field :data, [model_data_type], null: false
      end)
    end
  end
end
