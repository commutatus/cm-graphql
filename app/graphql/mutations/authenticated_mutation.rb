module Mutations
  class AuthenticatedMutation < BaseMutation
    def self.authorized?(object, context)
      context[:current_user].present?
    end
  end
end
