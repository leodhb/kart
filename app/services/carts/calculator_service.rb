module Carts
  class CalculatorService < ApplicationService
    attr_reader :cart_params, :cart_reference, :cart_items, :discount_rule

    def initialize(cart_params:, discount_rule: DiscountRule.current)
      @cart_params = cart_params
      @discount_rule = discount_rule
    end

    def call
      validation_result = validate_with_schema(CartSchema, cart_params)
      return validation_result unless validation_result[:success]

      validated_cart = validation_result[:data]
      @cart_reference = validated_cart[:reference]
      @cart_items = validated_cart[:line_items]

      begin
        apply_discount_to(cheapest_eligible_item) if discount_applicable?
        result = build_summary

        success_result(result)
      rescue StandardError => e
        failure_result({ error: e.message })
      end
    end

    private

    def apply_discount_to(item)
      original_price = item[:price]
      discount_rate = discount_rule.discount_value / 100
      final_price = original_price - (original_price * discount_rate).floor

      item[:discount_amount] = (original_price - final_price)
      item[:final_price] = final_price
    end

    def discount_applicable?
      return false unless discount_rule

      prerequisite_items.any? && eligible_items.any? && discount_applicable_items.size >= 2
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

    def discount_applicable_items
      return [] unless discount_rule

      cart_items.select do |item|
        discount_rule.prerequisite_skus.include?(item[:sku]) ||
        discount_rule.eligible_skus.include?(item[:sku])
      end
    end
  end
end
