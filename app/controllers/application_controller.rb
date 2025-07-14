class ApplicationController < ActionController::API
  before_action :underscore_params!

  private

  def underscore_params!
    params.deep_transform_keys!(&:underscore)
  end

  def camelize_keys(hash)
    hash.deep_transform_keys { |key| key.to_s.camelize(:lower) }
  end

  def render(json:, status: :ok)
    super(json: camelize_keys(json), status: status)
  end
end
