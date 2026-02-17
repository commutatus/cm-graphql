module CmGraphql
  module Extensions
    class RecaptchaExtension < GraphQL::Schema::FieldExtension
      
      # Wrapper to satisfy RelayClassicMutation's to_kwargs expectation
      InputWrapper = Struct.new(:data) do
        def to_kwargs
          data
        end

        def to_h
          data
        end
      end

      def apply
        input_arg = field.arguments["input"]
        input_type = input_arg.type.unwrap
        input_type.argument(:recaptcha_token, String, required: true)
      end

      def resolve(object:, arguments:, context:, **_rest)
        args_hash = arguments.to_h
        input_hash = args_hash[:input].to_h
        recaptcha_token = input_hash[:recaptcha_token]

        RecaptchaVerifier.verify_v3!(
          token: recaptcha_token,
          action: options[:action] || field.name.to_s,
          remote_ip: context[:request]&.remote_ip,
          minimum_score: options[:minimum_score] || RECAPTCHA_MINIMUM_SCORE
        )

        next_input = InputWrapper.new(input_hash.except(:recaptcha_token))
        yield(object, args_hash.except(:input).merge(input: next_input), nil)
      end
    end
  end
end