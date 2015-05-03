class Actions::AddField
  extend Extensions::Parameterizable

  with :field, :entity

  def call(app)
    entity = entity_for(app)
    if app.has_field?(entity['name'], field['name'])
      Result::Failed.new(name: ['already exists'])
    else
      entity['fields'] << params.field.to_h
    end
  end

  private

  def entity_for(app)
    app.app_config.entity name: field['entity']
  end
end
