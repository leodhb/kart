class Api::V1::CartsController < ApplicationController
  def calculate
    result = Carts::CalculatorService.new(cart_params:).call

    if result[:success]
      render json: CartSummaryBlueprint.render(result[:data]), status: :ok
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end

  private

  def cart_params
    params.require(:cart).permit(:reference, line_items: [ :name, :sku, :price ])
  end
end
