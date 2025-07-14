require 'rails_helper'

RSpec.describe "Api::V1::Carts", type: :request do
  describe "POST /api/v1/carts/calculate" do
    let(:json_response) { JSON.parse(response.body) }
    let(:request) { post '/api/v1/carts/calculate', params:, as: :json }

    context "with valid parameters" do
      let(:params) do
        {
          cart: {
            reference: 'cart_123',
            lineItems: [
              { name: 'Chocolate', sku: 'CHOCOLATE', price: "32.00" },
              { name: 'Vanilla', sku: 'VANILLA', price: "48.00" }
            ]
          }
        }
      end

      it "calculates the cart summary successfully" do
        request
        expect(response).to have_http_status(:success)
        expect(json_response['reference']).to be_present
        expect(json_response['items'].size).to eq(2)
        expect(json_response['totalPrice']).to be_present
      end
    end
    
    context "with invalid parameters" do
      let(:params) do
        {
          cart: {
            reference: nil,
          }
        }
      end

      it "returns an error for missing reference" do
        request
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to include(
          'reference' => ['must be filled'],
          'line_items' => ['is missing']
        )
      end
    end
  end
end
