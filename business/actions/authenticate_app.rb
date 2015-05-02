class Actions::AuthenticateApp
  extend Extensions::Parameterizable

  with :verb, :query_string, :auth

  TOLERANCE = 1.minute

  def call
    auth.values.any?(&:empty?) and
      fail InvalidCredentials

    app = Models::App.find_by public_key: auth.fetch(:public_key)

    valid_request?(app) or
      fail InvalidCredentials

    app
  rescue InvalidCredentials => e
    block_given? ? yield(e) : raise
  end

  InvalidCredentials = Class.new(StandardError)

  private

  def valid_request?(app)
    ( not expired? ) && valid_hmac?(app)
  end

  def valid_hmac?(app)
    auth.fetch(:hmac) == calculate_hmac_for(app)
  end

  def calculate_hmac_for(app)
    OpenSSL::HMAC.hexdigest \
      OpenSSL::Digest.new('sha1'),
      app.private_key.secret,
      request_string
  end

  def request_string
    verb + auth.fetch(:timestamp).to_s + query_string
  end

  def expired?
    timestamp = Time.at(auth.fetch(:timestamp).to_i).to_i
    now_utc = Time.now.utc.to_i
    now_utc - TOLERANCE > timestamp
  end
end
