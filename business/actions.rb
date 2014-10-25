module Authentik
  class Actions::CreateApp
    extend Extensions::Parameterizable

    with :client_id, :name

    def call
      app = Models::App.new \
        name: name,
        private_key: Models::PrivateKey.new,
        client: Models::Client.find(client_id)

      app.save!
      app
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

    with :public_key, :private_key

    def call
      Models::App.find_by \
        public_key: public_key,
        'private_key.secret' => private_key
    end
  end
end
