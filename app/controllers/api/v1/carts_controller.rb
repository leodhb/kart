class Api::V1::CartsController < ApplicationController
  def calculate
    schema = CartSchema.call(cart_params.to_h)

    if schema.success?
      result = Carts::CalculatorService.new(cart: schema.to_h).call

      render json: CartSummaryBlueprint.render(result), status: :ok
    else
      render json: { errors: schema.errors.to_h }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: "Internal server error" }, status: :internal_server_error
  end

  private

  def cart_params
    params.require(:cart).permit(:reference, line_items: [ :name, :sku, :price ])
  end
end
