module CmGraphql
  module Extensions
    class InputWithoutRecaptchaToken
      ToHOnly = Struct.new(:data) do
        def to_h
          data
        end
      end

      def initialize(input)
        @input = input
      end

      def to_kwargs
        kwargs = @input.to_kwargs
        return kwargs unless kwargs.respond_to?(:to_h)

        input_hash = kwargs.to_h
        return kwargs unless input_hash.is_a?(Hash)

        sanitized = input_hash.dup
        sanitized.delete(:recaptcha_token)

        ToHOnly.new(sanitized)
      end
    end
  end
end
