require 'ostruct'

class Repositories::Entities < OpenStruct
  def all
    app.reload.app_config.entities
  end

  def add(params)
    entity = OpenStruct.new params

    validations = validate entity

    if validations.ok?
      set = app.app_config.entities
      set << {
        'name' => entity.name,
        'fields' => internal_fields
      }
      app.app_config.update_attributes entities: set
    end

    validations
  end

  private

  def validate(field)
    EntityValidations.new.validate field, context: all
  end

  class EntityValidations
    include Validation

    validate :name, with: Validators::Presence
    validate :name, with: Validators::Uniqueness
  end

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
