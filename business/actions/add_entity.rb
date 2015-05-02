class Actions::AddEntity
  extend Extensions::Parameterizable

  with :name

  def call(app)
    set = app.app_config.entities
    if set.none? { |item| item['name'] == name.to_s }
      set << { 'name' => name, 'fields' => internal_fields }
      app.app_config.update_attributes entities: set
    end
  end

  private

  def internal_fields
    [
      {
        'name' => 'id',
        'type' => 'text',
        'internal' => true,
        'validates' => ['presence', 'uniqueness']
      },
      {
        'name' => 'created_at',
        'type' => 'datetime',
        'internal' => true,
        'validates' => ['presence']
      },
      {
        'name' => 'updated_at',
        'type' => 'datetime',
        'internal' => true,
        'validates' => ['presence']
      }
    ]
  end
end
