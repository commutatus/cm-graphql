module Types::Objects
  class <%= @model_name.titleize %>Type < Types::BaseObject

    graphql_name "<%= @model_name.titleize %>"

    field :id,                  Integer, null: false
  end
end