class RecaptchaVerificationFailed < BaseException
  def initialize(message = nil)
    super(message)
  end

  def message
    @message || 'Recaptcha verification failed'
  end

  def code
    :unprocessable_entity
  end

  def sub_code
    :recaptcha_verification_failed
  end
end
