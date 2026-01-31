require 'net/http'
require 'json'

class RecaptchaVerifier
  VERIFY_URL = URI('https://www.google.com/recaptcha/api/siteverify').freeze

  def self.verify_v3(token:, action:, remote_ip: nil, minimum_score: 0.5)
    secret = Rails.application.credentials.dig(:gcp, :recaptcha_secret_key)
    return false if secret.blank? || token.blank?

    response = post_verify(secret:, token:, remote_ip:)
    return false unless response.is_a?(Hash)

    return false unless response['success'] == true
    return false if response['action'].present? && response['action'] != action

    score = response['score']
    return true if score.nil?

    score.to_f >= minimum_score.to_f
  end

  def self.verify_v3!(token:, action:, remote_ip: nil, minimum_score: 0.5)
    success = verify_v3(token:, action:, remote_ip:, minimum_score:)
    raise RecaptchaVerificationFailed unless success

    true
  end

  def self.post_verify(secret:, token:, remote_ip: nil)
    request = Net::HTTP::Post.new(VERIFY_URL)
    request.set_form_data({ secret:, response: token }.tap { |h| h[:remoteip] = remote_ip if remote_ip.present? })

    http = Net::HTTP.new(VERIFY_URL.host, VERIFY_URL.port)
    http.use_ssl = true

    raw_response = http.request(request)
    JSON.parse(raw_response.body)
  rescue JSON::ParserError, SocketError, Timeout::Error, Errno::ECONNRESET, Errno::ECONNREFUSED
    false
  end

  private_class_method :post_verify
end
