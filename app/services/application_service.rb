class ApplicationService
  def call
    raise NotImplementedError, "Subclasses must implement the #call method"
  end

  private

  def success_result(data)
    {
      success: true,
      data: data,
      errors: nil
    }
  end

  def failure_result(errors)
    {
      success: false,
      data: nil,
      errors: errors
    }
  end

  def validate_with_schema(schema_class, data)
    result = schema_class.call(data.to_h)
    return success_result(result.to_h) if result.success?

    failure_result(result.errors.to_h)
  end
end
