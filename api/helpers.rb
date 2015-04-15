module AuthHelpers
  extend ::Grape::API::Helpers

  def current_app
    @current_app ||=
      begin
        if auth_data[:auth][:public_key] == "missing"
          error!({}, 404)
        end

        Actions::AuthenticateApp.new(auth_data).call do
          error!({ errors: ["Unauthorized"] }, 401)
        end
      end
  end
  alias_method :authenticate_app!, :current_app

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
      hmac: headers.fetch("Hmac") { "missing" },
      timestamp: headers.fetch("Timestamp") { "missing" },
      public_key: headers.fetch("Publickey") { "missing" }
    }
  end
end
