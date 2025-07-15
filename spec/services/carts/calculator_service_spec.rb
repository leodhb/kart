require 'rails_helper'

RSpec.describe Carts::CalculatorService, type: :service do
  let(:cart_params) do
    {
      reference: 'cart123',
      line_items: [
        { name: 'Item 1', price: "29.90", sku: 'SKU1' },
        { name: 'Item 2', price: "39.90", sku: 'SKU2' }
      ]
    }
  end

  let(:discount_rule) { create(:discount_rule, prerequisite_skus: [ 'SKU1' ], eligible_skus: [ 'SKU2' ], discount_value: 50) }

  subject { described_class.new(cart_params:, discount_rule:) }

  describe '#call' do
    it 'calculates total price with discount applied' do
      result = subject.call

      expect(result[:success]).to be true
      data = result[:data]
      expect(data[:reference]).to eq('cart123')
      expect(data[:items].size).to eq(2)
      expect(data[:items][0][:final_price]).to eq(2990)
      expect(data[:items][1][:final_price]).to eq(1995)
      expect(data[:total_price]).to eq(4985)
    end

    it 'returns discount amount for all items' do
      result = subject.call

      expect(result[:success]).to be true
      data = result[:data]
      expect(data[:items][0][:discount_amount]).to eq(0)
      expect(data[:items][1][:discount_amount]).to eq(1995)
    end

    context 'when no discount rule is provided' do
      subject { described_class.new(cart_params: cart_params) }

      context 'when singleton discount rule exists' do
        before do
          create(:discount_rule, prerequisite_skus: [ 'SKU1' ], eligible_skus: [ 'SKU2' ], discount_value: 50)
        end

        it 'calculates total price with the singleton discount' do
          result = subject.call

          expect(result[:success]).to be true
          data = result[:data]
          expect(data[:items][0][:final_price]).to eq(2990)
          expect(data[:items][1][:final_price]).to eq(1995)
          expect(data[:total_price]).to eq(4985)
        end
      end


      context 'when no discount rule exists' do
        it 'calculates total price without any discount' do
          result = subject.call

          expect(result[:success]).to be true
          data = result[:data]
          expect(data[:items][0][:final_price]).to eq(2990)
          expect(data[:items][1][:final_price]).to eq(3990)
          expect(data[:total_price]).to eq(6980)
        end
      end
    end

    context 'when a product is both a prerequisite and eligible item' do
      let(:discount_rule) do
        create(:discount_rule, prerequisite_skus: [ 'SKU1' ], eligible_skus: [ 'SKU1' ], discount_value: 50)
      end

      context 'when product appears only once' do
        let(:cart_params) do
          {
            reference: 'cart123',
            line_items: [
              { name: 'Item 1', price: "29.90", sku: 'SKU1' }
            ]
          }
        end

        it 'does not apply the discount' do
          result = subject.call

          expect(result[:success]).to be true
          data = result[:data]
          expect(data[:items][0][:final_price]).to eq(2990)
          expect(data[:total_price]).to eq(2990)
        end
      end

      context 'when product appears multiple times' do
        let(:cart_params) do
          {
            reference: 'cart123',
            line_items: [
              { name: 'Item 1', price: "29.90", sku: 'SKU1' },
              { name: 'Item 1', price: "29.90", sku: 'SKU1' },
              { name: 'Item 1', price: "29.90", sku: 'SKU1' }
            ]
          }
        end

        it 'applies the discount to the cheapest eligible item' do
          result = subject.call

          expect(result[:success]).to be true
          data = result[:data]
          expect(data[:items][0][:final_price]).to eq(1495)
          expect(data[:items][1][:final_price]).to eq(2990)
          expect(data[:items][2][:final_price]).to eq(2990)
          expect(data[:total_price]).to eq(7475)
        end
      end

      context 'when product appears alongside an item that is not eligible or a prerequisite' do
        let(:cart_params) do
          {
            reference: 'cart123',
            line_items: [
              { name: 'Item 1', price: "29.90", sku: 'SKU1' },
              { name: 'Item 2', price: "39.90", sku: 'SKU2' }
            ]
          }
        end

        it 'does not apply the discount' do
          result = subject.call

          expect(result[:success]).to be true
          data = result[:data]
          expect(data[:items][0][:final_price]).to eq(2990)
          expect(data[:items][1][:final_price]).to eq(3990)
          expect(data[:total_price]).to eq(6980)
        end
      end
    end

    context 'when products generates a non-integer final price' do
      let(:cart_params) do
        {
          reference: 'cart123',
          line_items: [
            { name: 'Item 1', price: "29.90", sku: 'SKU1' },
            { name: 'Item 2', price: "39.93", sku: 'SKU2' }
          ]
        }
      end

      it 'rounds down the discount amount to the nearest integer' do
        result = subject.call

        expect(result[:success]).to be true
        data = result[:data]
        expect(data[:items][1][:discount_amount]).to eq(1996)
        expect(data[:items][1][:final_price]).to eq(1997)
        expect(data[:total_price]).to eq(4987)
      end
    end

    context 'when cart is empty' do
      let(:cart_params) { { reference: 'cart123', line_items: [] } }

      it 'returns an empty summary' do
        result = subject.call

        expect(result[:success]).to be true
        data = result[:data]
        expect(data[:reference]).to eq('cart123')
        expect(data[:items]).to be_empty
        expect(data[:total_price]).to eq(0)
      end
    end

    context 'when discount rule is nil' do
      let(:discount_rule) { nil }

      it 'returns the cart without any discounts applied' do
        result = subject.call

        expect(result[:success]).to be true
        data = result[:data]
        expect(data[:reference]).to eq('cart123')
        expect(data[:items].size).to eq(2)
        expect(data[:items][0][:final_price]).to eq(2990)
        expect(data[:items][1][:final_price]).to eq(3990)
        expect(data[:total_price]).to eq(6980)
      end
    end

    context 'when discount rule is not applicable' do
      let(:discount_rule) { create(:discount_rule, prerequisite_skus: [ 'SKU3' ], eligible_skus: [ 'SKU4' ], discount_value: 50) }

      it 'returns the cart without any discounts applied' do
        result = subject.call

        expect(result[:success]).to be true
        data = result[:data]
        expect(data[:reference]).to eq('cart123')
        expect(data[:items].size).to eq(2)
        expect(data[:items][0][:final_price]).to eq(2990)
        expect(data[:items][1][:final_price]).to eq(3990)
        expect(data[:total_price]).to eq(6980)
      end
    end
  end
end
