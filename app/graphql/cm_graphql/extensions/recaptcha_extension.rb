require_relative 'input_without_recaptcha_token'

module CmGraphql
  module Extensions
    class RecaptchaExtension < GraphQL::Schema::FieldExtension
      def apply
        input_arg = field.arguments&.dig(:input) || field.arguments&.dig("input")
        input_type = unwrap_type(input_arg&.type)

        if input_type&.respond_to?(:argument)
          input_type.argument(:recaptcha_token, String, required: true)
        else
          field.argument(:recaptcha_token, String, required: true)
        end
      end
 
      def resolve(object:, arguments:, context:, **_rest)
        ruby_kwargs = arguments.respond_to?(:keyword_arguments) ? arguments.keyword_arguments : arguments
        recaptcha_token = extract_recaptcha_token(ruby_kwargs[:input])

        RecaptchaVerifier.verify_v3!(
          token: recaptcha_token,
          action: options[:action] || field.name.to_s,
          remote_ip: context[:request]&.remote_ip,
          minimum_score: options[:minimum_score] || RECAPTCHA_MINIMUM_SCORE
        )

        forwarded_kwargs = ruby_kwargs.dup
        forwarded_kwargs[:input] = sanitize_input(forwarded_kwargs[:input])
        forwarded_kwargs.delete(:recaptcha_token)

        yield(object, forwarded_kwargs, nil)
      end

      private

      def extract_recaptcha_token(ruby_kwargs)
        input = ruby_kwargs[:input]
        input_hash = input_to_hash(input)

        if input_hash.is_a?(Hash)
          input_hash[:recaptcha_token] || input_hash["recaptcha_token"]
        else
          ruby_kwargs[:recaptcha_token]
        end
      end

      def sanitize_input(input)
        return nil if input.nil?
        return CmGraphql::Extensions::InputWithoutRecaptchaToken.new(input) if input.respond_to?(:to_kwargs)

        input_hash = input_to_hash(input)
        return input_hash unless input_hash.is_a?(Hash)

        sanitized = input_hash.dup
        sanitized.delete(:recaptcha_token)
        sanitized
      end

      def input_to_hash(input)
        return nil if input.nil?

        if input.respond_to?(:to_kwargs)
          kwargs = input.to_kwargs
          kwargs.respond_to?(:to_h) ? kwargs.to_h : nil
        elsif input.respond_to?(:keyword_arguments)
          input.keyword_arguments
        elsif input.respond_to?(:to_h)
          input.to_h
        elsif input.is_a?(Hash)
          input
        end
      end

      def unwrap_type(type)
        return nil unless type
        type = type.of_type while type.respond_to?(:of_type)
        type
      end
    end
  end
end