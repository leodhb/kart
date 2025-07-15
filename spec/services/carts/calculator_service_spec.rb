require 'rails_helper'

RSpec.describe Carts::CalculatorService, type: :service do
  let(:cart) do
    CartSchema.call(
      reference: 'cart123',
      line_items: [
        { name: 'Item 1', price: "29.90", sku: 'SKU1' },
        { name: 'Item 2', price: "39.90", sku: 'SKU2' }
      ]
    ).to_h
  end

  let(:discount_rule) { create(:discount_rule, prerequisite_skus: [ 'SKU1' ], eligible_skus: [ 'SKU2' ], discount_value: 50) }

  subject { described_class.new(cart:, discount_rule:) }

  describe '#call' do
    it 'calculates total price with discount applied' do
      result = subject.call

      expect(result[:reference]).to eq('cart123')
      expect(result[:items].size).to eq(2)
      expect(result[:items][0][:final_price]).to eq(2990)
      expect(result[:items][1][:final_price]).to eq(1995)
      expect(result[:total_price]).to eq(4985)
    end

    it 'returns discount amount for all items' do
      result = subject.call

      expect(result[:items][0][:discount_amount]).to eq(0)
      expect(result[:items][1][:discount_amount]).to eq(1995)
    end

    context 'when no discount rule is provided' do
      subject { described_class.new(cart:) }

      context 'when singleton discount rule exists' do
        before do
          create(:discount_rule, prerequisite_skus: [ 'SKU1' ], eligible_skus: [ 'SKU2' ], discount_value: 50)
        end

        it 'calculates total price with the singleton discount' do
          result = subject.call

          expect(result[:items][0][:final_price]).to eq(2990)
          expect(result[:items][1][:final_price]).to eq(1995)
          expect(result[:total_price]).to eq(4985)
        end
      end


      context 'when no discount rule exists' do
        it 'calculates total price without any discount' do
          result = subject.call

          expect(result[:items][0][:final_price]).to eq(2990)
          expect(result[:items][1][:final_price]).to eq(3990)
          expect(result[:total_price]).to eq(6980)
        end
      end
    end

    context 'when a product is both a prerequisite and eligible item' do
      let(:discount_rule) do
        create(:discount_rule, prerequisite_skus: [ 'SKU1' ], eligible_skus: [ 'SKU1' ], discount_value: 50)
      end

      context 'when product appears only once' do
        let(:cart) do
          CartSchema.call(
            reference: 'cart123',
            line_items: [
              { name: 'Item 1', price: "29.90", sku: 'SKU1' }
            ]
          ).to_h
        end

        it 'does not apply the discount' do
          result = subject.call

          expect(result[:items][0][:final_price]).to eq(2990)
          expect(result[:total_price]).to eq(2990)
        end
      end

      context 'when product appears multiple times' do
        let(:cart) do
          CartSchema.call(
            reference: 'cart123',
            line_items: [
              { name: 'Item 1', price: "29.90", sku: 'SKU1' },
              { name: 'Item 1', price: "29.90", sku: 'SKU1' },
              { name: 'Item 1', price: "29.90", sku: 'SKU1' }
            ]
          ).to_h
        end

        it 'applies the discount to the first occurrence only' do
          result = subject.call

          expect(result[:items][0][:final_price]).to eq(1495)
          expect(result[:items][1][:final_price]).to eq(2990)
          expect(result[:items][2][:final_price]).to eq(2990)
          expect(result[:total_price]).to eq(7475)
        end
      end

      context 'when product appears alongside an item that is not eligible or a prerequisite' do
        let(:cart) do
          CartSchema.call(
            reference: 'cart123',
            line_items: [
              { name: 'Item 1', price: "29.90", sku: 'SKU1' },
              { name: 'Item 2', price: "39.90", sku: 'SKU2' }
            ]
          ).to_h
        end

        it 'does not apply the discount' do
          result = subject.call

          expect(result[:items][0][:final_price]).to eq(2990)
          expect(result[:items][1][:final_price]).to eq(3990)
          expect(result[:total_price]).to eq(6980)
        end
      end
    end

    context 'when products generates a non-integer final price' do
      let(:cart) do
        CartSchema.call(
          reference: 'cart123',
          line_items: [
            { name: 'Item 1', price: "29.90", sku: 'SKU1' },
            { name: 'Item 2', price: "39.93", sku: 'SKU2' }
          ]
        ).to_h
      end

      it 'rounds down the discount amount to the nearest integer' do
        result = subject.call

        expect(result[:items][1][:discount_amount]).to eq(1996)
        expect(result[:items][1][:final_price]).to eq(1997)
        expect(result[:total_price]).to eq(4987)
      end
    end

    context 'when cart is empty' do
      let(:cart) { CartSchema.call(reference: 'cart123', line_items: []).to_h }

      it 'returns an empty summary' do
        result = subject.call

        expect(result[:reference]).to eq('cart123')
        expect(result[:items]).to be_empty
        expect(result[:total_price]).to eq(0)
      end
    end

    context 'when discount rule is nil' do
      let(:discount_rule) { nil }

      it 'returns the cart without any discounts applied' do
        result = subject.call

        expect(result[:reference]).to eq('cart123')
        expect(result[:items].size).to eq(2)
        expect(result[:items][0][:final_price]).to eq(2990)
        expect(result[:items][1][:final_price]).to eq(3990)
        expect(result[:total_price]).to eq(6980)
      end
    end

    context 'when discount rule is not applicable' do
      let(:discount_rule) { create(:discount_rule, prerequisite_skus: [ 'SKU3' ], eligible_skus: [ 'SKU4' ], discount_value: 50) }

      it 'returns the cart without any discounts applied' do
        result = subject.call

        expect(result[:reference]).to eq('cart123')
        expect(result[:items].size).to eq(2)
        expect(result[:items][0][:final_price]).to eq(2990)
        expect(result[:items][1][:final_price]).to eq(3990)
        expect(result[:total_price]).to eq(6980)
      end
    end
  end
end
