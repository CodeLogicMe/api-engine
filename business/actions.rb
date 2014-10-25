module Authentik
  class Actions::CreateApp
    extend Extensions::Parameterizable

    with :name

    def call
      app = Models::App.create name: name
      Models::PrivateKey.create app: app
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
end
