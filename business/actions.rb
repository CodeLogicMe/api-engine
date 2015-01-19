module RestInMe
  class Actions::CreateApp
    extend Extensions::Parameterizable

    with :name, :client

    def call
      Models::App.create \
        client: client,
        name: name
    end
  end

  class Actions::NewPrivateKey
    extend Extensions::Parameterizable

    with :public_key

    def call
      app = Models::App.find_by public_key: public_key

      Models::PrivateKey.create app: app
    end
  end

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
      timestamp = Time.parse(auth.fetch(:timestamp))
      now_utc = Time.now.utc.to_i
      now_utc - TOLERANCE > timestamp.to_i
    end
  end

  class AddEntity
    extend Extensions::Parameterizable

    with :name, :fields

    def call(app)
      set = app.app_config.entities
      if set.none? { |item| item['name'] == name }
        set << { name: name, fields: fields }
        app.app_config.update_attributes \
          entities: set
      end
    end
  end
end
