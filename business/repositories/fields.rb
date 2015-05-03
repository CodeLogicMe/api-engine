class Repositories::Fields < OpenStruct
  def all
    entity[:fields]
  end

  def add(params)
    field = OpenStruct.new params

    validations = validate field

    if validations.ok?
      attrs = field.to_h
      attrs.delete 'entity'
      entity[:fields] << attrs
      app.save!
    end

    validations
  end

  def exists?(name)
    entity.fields.any? do |field_config|
      field_config['name'].to_s == name.to_s
    end
  end

  def validate(field)
    FieldValidations.new.validate field, context: all
  end

  private

  class FieldValidations
    include Validation

    validate :name, with: Validators::Presence
    validate :name, with: Validators::Uniqueness
    validate :type, with: Validators::Presence
  end
end
