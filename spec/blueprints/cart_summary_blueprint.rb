require 'rails_helper'

RSpec.describe CartSummaryBlueprint, type: :blueprint do
  let(:cart_summary) do
    {
      reference: 'cart_123',
      items: [
        {
          name: 'Chocolate',
          sku: 'CHOCOLATE',
          price: 3200,
          discount_amount: 1600,
          final_price: 1600
        }
      ],
      total_price: 1600
    }
  end

  it 'renders the cart summary correctly' do
    rendered = CartSummaryBlueprint.render_as_hash(cart_summary)
    expect(rendered).to eq(
      reference: 'cart_123',
      items: [
        {
          name: 'Chocolate',
          sku: 'CHOCOLATE',
          price: "32.00",
          discountAmount: "16.00",
          finalPrice: "16.00"
        }
      ],
      totalPrice: "16.00"
    )
  end
end
