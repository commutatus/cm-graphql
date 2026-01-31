module Mutations
  class RecaptchaMutation < BaseMutation
    argument :recaptcha_token, String, required: true

    def resolve(**args)
      recaptcha_token = args.delete(:recaptcha_token)
      remote_ip = context[:request]&.remote_ip

      RecaptchaVerifier.verify_v3!(
        token: recaptcha_token,
        action: self.class.recaptcha_action,
        remote_ip: remote_ip,
        minimum_score: self.class.recaptcha_minimum_score
      )

      perform(**args)
    end

    def self.recaptcha_action
      name.to_s.underscore
    end

    def self.recaptcha_minimum_score
      MINIMUM_RECAPTCHA_SCORE
    end
  end
end
