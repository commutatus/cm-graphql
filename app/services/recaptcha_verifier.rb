require 'net/http'
require 'json'

class RecaptchaVerifier
  API_HOST = 'recaptchaenterprise.googleapis.com'

  def self.verify_v3(token:, action:, remote_ip: nil, minimum_score: 0.5)
    project_id = Rails.application.credentials.dig(:gcp, :recaptcha_enterprise_project_id)
    site_key = Rails.application.credentials.dig(:gcp, :recaptcha_site_key)
    api_key = Rails.application.credentials.dig(:gcp, :recaptcha_api_key)

    if project_id.blank? || site_key.blank? || api_key.blank?
      raise RecaptchaVerificationFailed,
            'Please configure recaptcha enterprise credentials at Rails.application.credentials.dig(:gcp, :recaptcha_enterprise_project_id), :recaptcha_site_key, :recaptcha_api_key.'
    end

    raise RecaptchaVerificationFailed, 'Recaptcha token missing' if token.blank?

    response = create_assessment(project_id:, site_key:, api_key:, token:, action:, remote_ip:)
    raise RecaptchaVerificationFailed, 'Invalid response from recaptcha' unless response.is_a?(Hash)

    token_props = response['tokenProperties']
    unless token_props.is_a?(Hash)
      raise RecaptchaVerificationFailed, 'Invalid response from recaptcha'
    end

    unless token_props['valid'] == true
      reason = token_props['invalidReason']
      raise RecaptchaVerificationFailed, reason.present? ? "Recaptcha invalid token: #{reason}" : 'Recaptcha invalid token'
    end

    if token_props['action'].present? && token_props['action'] != action
      raise RecaptchaVerificationFailed, 'Recaptcha action mismatch'
    end

    risk = response['riskAnalysis']
    score = risk.is_a?(Hash) ? risk['score'] : nil
    return true if score.nil?

    score.to_f >= minimum_score.to_f
  end

  def self.verify_v3!(token:, action:, remote_ip: nil, minimum_score: 0.5)
    success = verify_v3(token:, action:, remote_ip:, minimum_score:)
    raise RecaptchaVerificationFailed unless success

    true
  end

  def self.create_assessment(project_id:, site_key:, api_key:, token:, action:, remote_ip: nil)
    uri = URI::HTTPS.build(
      host: API_HOST,
      path: "/v1/projects/#{project_id}/assessments",
      query: URI.encode_www_form(key: api_key)
    )

    event = {
      token: token,
      siteKey: site_key,
      expectedAction: action
    }
    event[:userIpAddress] = remote_ip if remote_ip.present?

    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate({ event: event })

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    raw_response = http.request(request)
    body = raw_response.body.to_s

    parsed_body = JSON.parse(body)

    unless raw_response.is_a?(Net::HTTPSuccess)
      error_message = parsed_body.dig('error', 'message')
      raise RecaptchaVerificationFailed,
            "Recaptcha enterprise HTTP #{raw_response.code}: #{error_message.presence || raw_response.message}"
    end

    parsed_body
  rescue JSON::ParserError
    raise RecaptchaVerificationFailed, "Recaptcha enterprise returned invalid JSON"
  rescue SocketError, Timeout::Error, Errno::ECONNRESET, Errno::ECONNREFUSED
    raise RecaptchaVerificationFailed, 'Recaptcha enterprise request failed'
  end

  private_class_method :create_assessment
end
