module AuthHelpers
  extend ::Grape::API::Helpers

  def current_api
    env['current_api']
  end

  private

  def auth_data
    @auth_data ||= {
      verb: verb,
      auth: auth_keys,
      query_string: params_string
    }
  end

  def verb
    env.fetch "REQUEST_METHOD"
  end

  def params_string
    case env.fetch("REQUEST_METHOD")
    when "GET"
      env.fetch "QUERY_STRING"
    else
      env.fetch("rack.request.form_hash").to_query
    end
  end

  def auth_keys
    {
      hmac: headers.fetch('X-Request-Hash') { 'missing' },
      timestamp: headers.fetch('X-Request-Timestamp') { 'missing' },
      public_key: headers.fetch('X-Access-Token') { 'missing' }
    }
  end
end
