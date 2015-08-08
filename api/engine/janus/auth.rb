module Janus
  class Auth
    TOLERANCE = 1.minute

    def initialize(headers)
      @public_key = headers.fetch('X_ACCESS_TOKEN') { 'missing' }
      @timestamp = headers.fetch('X_REQUEST_TIMESTAMP') { 'missing' }
      @request_hash = headers.fetch('X_REQUEST_HASH') { 'missing' }
    end

    def identifiable?
      ( @public_key != 'missing' ) and ( not api.nil? )
    end

    def api
      @api ||= Models::Api
        .includes(:private_key)
        .find_by(public_key: @public_key)
    end

    def valid?(verb, query)
      has_all_info? and
        ( not expired? ) and hash_checks?(verb, query)
    end

    private

    def has_all_info?
      [@public_key, @timestamp, @request_hash]
        .all? { |value| value != 'missing' }
    end

    def expired?
      timestamp = Time.at(@timestamp.to_i).to_i
      now_utc = Time.now.utc.to_i
      ( now_utc - TOLERANCE ) > timestamp
    end

    def hash_checks?(verb, query)
      hash = OpenSSL::HMAC.hexdigest \
        OpenSSL::Digest.new('sha1'),
        api.private_key.secret,
        request_string(verb, query)

      @request_hash == hash
    end

    def request_string(verb, query)
      verb + @timestamp + query
    end
  end
end
