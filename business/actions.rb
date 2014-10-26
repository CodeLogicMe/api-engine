module Authk
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

    def call
      app = Models::App.find_by public_key: auth[:public_key]

      fail InvalidCredentials unless has_valid_hmac? app

      app
    rescue InvalidCredentials => e
      block_given? ? yield(e) : raise
    end

    InvalidCredentials = Class.new(StandardError)

    private

    def has_valid_hmac?(app)
      auth[:hmac] == calculate_hmac_for(app)
    end

    def calculate_hmac_for(app)
      OpenSSL::HMAC.digest \
        OpenSSL::Digest.new('sha1'),
        app.private_key.secret,
        request_string
    end

    def request_string
      verb + query_string
    end
  end

  class Actions::CreateUser
    extend Extensions::Parameterizable

    with :app, :params

    def call
      user = Models::User.new \
        app: app,
        email: params[:email],
        password: params[:password]

      user.save!
      user
    rescue Mongoid::Errors::Validations
      block_given? ? yield(user.errors.full_messages) : raise
    end
  end

  class Actions::AuthenticateUser
    extend Extensions::Parameterizable

    with :app, :email, :password

    def call
      user = app.users.find_by email: email

      unless user.password_checks? password
        fail InvalidPassword
      end

      user
    rescue ::Mongoid::Errors::DocumentNotFound, InvalidPassword
      block_given? ? yield : raise
    end

    InvalidPassword = Class.new(StandardError)
  end

  class Actions::SetLooseData
    extend Extensions::Parameterizable

    with :app, :user_id, :data

    def call
      user = app.users.find user_id

      user.loose_data.update_attributes! properties: data

      user.loose_data
    rescue ::Mongoid::Errors::DocumentNotFound => e
      block_given? ? yield : raise
    end
  end
end
