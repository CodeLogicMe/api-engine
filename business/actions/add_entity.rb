class Actions::AddEntity
  extend Extensions::Parameterizable

  with :name

  def call(app)
    set = app.app_config.entities
    if set.none? { |item| item['name'] == name.to_s }
      set << { name: name }
      app.app_config.update_attributes entities: set
    end
  end
end
