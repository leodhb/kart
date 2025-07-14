module Carts
  class CalculatorService
    attr_reader :cart_reference, :cart_items, :discount_rule

    def initialize(cart:, discount_rule: DiscountRule.current)
      @cart_reference = cart[:reference]
      @cart_items = cart[:line_items]
      @discount_rule = discount_rule
    end

    def call
      apply_discount_to(cheapest_eligible_item) if discount_applicable?

      build_summary
    end

    private

    def apply_discount_to(item)
      original_price = item[:price]
      discount_rate = discount_rule.discount_value / 100
      final_price = original_price - (original_price * discount_rate)

      item[:discount_amount] = (original_price - final_price)
      item[:final_price] = final_price
    end

    def discount_applicable?
      prerequisite_items.any? && eligible_items.any?
    end

    def build_summary
      items = cart_items.map do |item|
        build_item(item)
      end
  
      {
        reference: cart_reference,
        items: items,
        total_price: items.sum { |item| item[:final_price] }
      }
    end

    def build_item(item)
      {
        name: item[:name],
        sku: item[:sku],
        price: item[:price],
        discount_amount: item[:discount_amount] || 0,
        final_price: item[:final_price] || item[:price]
      }
    end

    def prerequisite_items
      return [] unless discount_rule

      cart_items.select do |item|
        discount_rule.prerequisite_skus.include?(item[:sku])
      end
    end

    def eligible_items
      return [] unless discount_rule

      cart_items.select do |item|
        discount_rule.eligible_skus.include?(item[:sku])
      end
    end

    def cheapest_eligible_item
      eligible_items.min_by { |item| item[:price] }
    end
  end
end
