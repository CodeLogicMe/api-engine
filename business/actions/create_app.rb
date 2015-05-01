class Actions::CreateApp
  extend Extensions::Parameterizable

  with :name, :client

  def call
    Models::App.create \
      client: client,
      name: name
  end
end
