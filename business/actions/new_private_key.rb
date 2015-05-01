class Actions::NewPrivateKey
  extend Extensions::Parameterizable

  with :public_key

  def call
    app = Models::App.find_by public_key: public_key

    Models::PrivateKey.create app: app
  end
end
