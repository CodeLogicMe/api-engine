require_relative '../setup'

class Actions::AuthenticateApi
  extend Extensions::Parameterizable

  TOLERANCE = 1.minute

  with :verb, :query_string, :auth

  def call
    auth.values.any?(&:empty?) and
      fail InvalidCredentials

    criteria = { public_key: auth.fetch(:public_key) }
    Models::Api.find_by!(criteria).tap do |api|
      valid_request?(api) or
        fail InvalidCredentials
    end
  rescue InvalidCredentials => e
    block_given? ? yield(e) : raise
  end

  InvalidCredentials = Class.new(StandardError)

  private

  def valid_request?(api)
    ( not expired? ) && valid_hash?(api)
  end

  def valid_hash?(api)
    auth.fetch(:hash) == calculate_hash_for(api)
  end

  def calculate_hash_for(api)
    OpenSSL::HMAC.hexdigest \
      OpenSSL::Digest.new('sha1'),
      api.private_key.secret,
      request_string
  end

  def request_string
    verb + auth.fetch(:timestamp).to_s + query_string
  end

  def expired?
    timestamp = Time.at(auth.fetch(:timestamp).to_i).to_i
    now_utc = Time.now.utc.to_i
    ( now_utc - TOLERANCE ) > timestamp
  end
end
