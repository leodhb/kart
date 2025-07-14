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
  end
end
