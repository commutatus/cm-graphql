module Queries
  class <%= @model_name.titleize %> < Queries::BaseQuery
    description "Fetch all or specific <%= @model_name.titleize %> detail"

    type Types::Objects::<%= @model_name.titleize %>ListType, null: true

    argument :paging, Types::Inputs::Base::Paging, required: false
    argument :sort, Types::Inputs::Base::Sort, required: false

    def resolve(paging: nil, filters: nil, sort: nil)
      raise Unauthorized, I18n.t("graphql.unauthorized") if (filters && filters.my) && Current.user.nil?
      ::<%= @model_name.titleize %>.all.list(paging&.per_page, paging&.page_no)
    end

  end
end
