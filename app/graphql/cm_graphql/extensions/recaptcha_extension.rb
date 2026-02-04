module CmGraphql
  module Extensions
    class RecaptchaExtension < GraphQL::Schema::FieldExtension
      def apply
        field.argument(:recaptcha_token, String, required: true)
      end
 
      def resolve(object:, arguments:, context:)
        RecaptchaVerifier.verify_v3!(
          token: arguments[:recaptcha_token],
          action: options[:action] || field.name.to_s,
          remote_ip: context[:request]&.remote_ip,
          minimum_score: options[:minimum_score] || RECAPTCHA_MINIMUM_SCORE
        )
        yield(object, arguments.except(:recaptcha_token))
      end
    end
  end
end