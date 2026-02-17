# frozen_string_literal: true

require 'graphql'
require_relative '../app/exceptions/base_exception'
require_relative '../app/exceptions/recaptcha_verification_failed'
require_relative '../config/initializers/constants'
require_relative '../app/services/recaptcha_verifier'
require_relative '../app/graphql/cm_graphql/extensions/recaptcha_extension'

# Mock Rails for testing
module Rails
  def self.application
    @app ||= Struct.new(:credentials).new(
      Struct.new(:dig).new(nil)
    )
  end
end

RSpec.describe CmGraphql::Extensions::RecaptchaExtension do
  # Test Input Type
  class TestInput < GraphQL::Schema::InputObject
    argument :name, String, required: true
  end

  # Test Mutation with InputObject
  class TestMutationWithInput < GraphQL::Schema::Mutation
    argument :input, TestInput, required: true

    field :success, Boolean, null: false

    def resolve(input:)
      { success: true }
    end
  end

  class TestMutationType < GraphQL::Schema::Object
    field :test_with_input, mutation: TestMutationWithInput, extensions: [CmGraphql::Extensions::RecaptchaExtension]
  end

  class TestQueryType < GraphQL::Schema::Object
    field :dummy, String, null: false

    def dummy
      "dummy"
    end
  end

  class TestSchema < GraphQL::Schema
    query TestQueryType
    mutation TestMutationType
  end

  before do
    # Stub RecaptchaVerifier to always pass
    allow(RecaptchaVerifier).to receive(:verify_v3!).and_return(true)
  end

  describe 'with InputObject input' do
    let(:query) do
      <<~GQL
        mutation TestWithInput($input: TestInput!) {
          testWithInput(input: $input) {
            success
          }
        }
      GQL
    end

    it 'adds recaptcha_token to the input type' do
      input_type = TestSchema.types['TestInput']
      expect(input_type.arguments.keys).to include('recaptchaToken')
    end

    it 'resolves successfully when recaptcha token is in input' do
      result = TestSchema.execute(
        query,
        variables: {
          input: {
            name: 'Test',
            recaptchaToken: 'test-token'
          }
        },
        context: { request: nil }
      )

      expect(result['errors']).to be_nil
      expect(result.dig('data', 'testWithInput', 'success')).to eq(true)
    end

    it 'calls RecaptchaVerifier with the token' do
      expect(RecaptchaVerifier).to receive(:verify_v3!).with(
        hash_including(token: 'test-token')
      )

      TestSchema.execute(
        query,
        variables: {
          input: {
            name: 'Test',
            recaptchaToken: 'test-token'
          }
        },
        context: { request: nil }
      )
    end

    it 'does not pass recaptcha_token to the resolver' do
      # We need to verify the resolver receives input WITHOUT recaptcha_token
      resolver_input = nil
      
      allow_any_instance_of(TestMutationWithInput).to receive(:resolve) do |instance, input:|
        resolver_input = input
        { success: true }
      end

      TestSchema.execute(
        query,
        variables: {
          input: {
            name: 'Test',
            recaptchaToken: 'test-token'
          }
        },
        context: { request: nil }
      )

      # The key test: resolver should receive input that can be converted to hash WITHOUT recaptcha_token
      input_hash = resolver_input.respond_to?(:to_h) ? resolver_input.to_h : resolver_input
      expect(input_hash).to eq({ name: 'Test' })
      expect(input_hash).not_to have_key(:recaptcha_token)
      expect(input_hash).not_to have_key(:recaptchaToken)
    end
  end

end
