module ApiSpecHelpers
  def last_json
    parse_json last_response
  end

  def parse_json(response)
    Hashie::Mash.new JSON.parse(response.body)
  end

  def calculate_hmac(verb, private_key, params, timestamp)
    digest = OpenSSL::Digest.new('sha1')
    data = verb + timestamp.to_s + params.to_query
    OpenSSL::HMAC.hexdigest(digest, private_key, data)
  end

  def set_auth_headers_for!(app, verb, params)
    timestamp = Time.now.utc.to_i
    header 'X-Access-Token', app.public_key
    header 'X-Request-Timestamp', timestamp.to_s
    header 'X-Request-Hash', calculate_hmac(verb, app.private_key.secret, params, timestamp)
  end

  def login_as(client)
    Grape::Endpoint.before_each do |endpoint|
      allow(endpoint).to receive(:current_client).and_return client
    end
  end
end
