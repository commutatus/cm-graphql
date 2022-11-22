module Types::Objects
  class <%= @model_name.titleize %>ListType < Types::BaseObject
    graphql_name "<%= @model_name.titleize %>ListType"

    field :paging, Types::Objects::Base::PagingType, null: true
    field :data, [Types::Objects::<%= @model_name.titleize %>Type], null: false
  end
end