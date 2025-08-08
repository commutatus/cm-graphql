module Types
  module PagingTypeHelper
    def self.paging_type_for_model(model:, record_data_type: nil, graphql_type_name: nil)
      Class.new(Types::BaseObject) do
        graphql_name(graphql_type_name.presence || "#{model}PagingType")

        model_data_type = if record_data_type.present?
                            record_data_type.to_s.constantize
                          else
                            "Types::Objects::#{model}Type".constantize
                          end

        field :paging, Types::Objects::Base::PagingType, null: true
        field :data, [model_data_type], null: false
      end
    end
  end
end
