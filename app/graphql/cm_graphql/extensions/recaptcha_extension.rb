module CmGraphql
  module Extensions
    class RecaptchaExtension < GraphQL::Schema::FieldExtension
      def apply
        if field.resolver
          field.resolver.argument(:recaptcha_token, String, required: true)
        else
          field.argument(:recaptcha_token, String, required: true)
        end
      end
 
      def resolve(object:, arguments:, context:)
        args_hash = arguments.to_h
        input_hash = args_hash[:input].respond_to?(:to_h) ? args_hash[:input].to_h : nil

        recaptcha_token = input_hash ? input_hash[:recaptcha_token] : args_hash[:recaptcha_token]

        RecaptchaVerifier.verify_v3!(
          token: recaptcha_token,
          action: options[:action] || field.name.to_s,
          remote_ip: context[:request]&.remote_ip,
          minimum_score: options[:minimum_score] || RECAPTCHA_MINIMUM_SCORE
        )

        if input_hash
          next_input = input_hash.dup
          next_input.delete(:recaptcha_token)
          yield(object, args_hash.merge(input: next_input))
        else
          yield(object, arguments.except(:recaptcha_token))
        end
      end
    end
  end
end