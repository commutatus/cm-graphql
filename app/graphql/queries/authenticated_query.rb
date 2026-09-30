# frozen_string_literal: true

module Queries
  class AuthenticatedQuery < Queries::BaseQuery
    def self.authorized?(_object, context)
      context[:current_user].present?
    end
  end
end
