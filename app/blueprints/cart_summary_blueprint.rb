class CartSummaryBlueprint < Blueprinter::Base
  identifier :reference

  field :items do |cart|
    cart[:items].map do |item|
      {
        name: item[:name],
        sku: item[:sku],
        price: Money.format_cents(item[:price]),
        discountAmount: Money.format_cents(item[:discount_amount]),
        finalPrice: Money.format_cents(item[:final_price])
      }
    end
  end

  field :totalPrice do |cart|
    Money.format_cents(cart[:total_price])
  end
end
