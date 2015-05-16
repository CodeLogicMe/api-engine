class Actions::NewPrivateKey
  extend Extensions::Parameterizable

  with :public_key

  def call
    api = Models::Api.find_by public_key: public_key

    Models::PrivateKey.create api: api
  end
end
