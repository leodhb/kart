class Api::V1::CartsController < ApplicationController
  def calculate
    render json: { message: "Cart calculation endpoint" }, status: :ok
  end
end
