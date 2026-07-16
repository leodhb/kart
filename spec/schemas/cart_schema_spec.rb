require 'rails_helper'

RSpec.describe CartSchema, type: :schema do
  describe 'validations' do
    it 'validates presence of reference' do
      result = CartSchema.call(reference: nil, line_items: [])
      expect(result.errors[:reference]).to include('must be filled')
    end

    it 'validates presence of line_items' do
      result = CartSchema.call(reference: 'cart123', line_items: nil)
      expect(result.errors[:line_items]).to include('must be an array')
    end

    it 'validates line items structure' do
      result = CartSchema.call(
        reference: 'cart123',
        line_items: [
          { name: 'Item 1', price: "29.90", sku: 'SKU1' },
          { name: '', price: "39.90", sku: 'SKU2' }
        ]
      )
      expect(result.errors[:line_items][1][:name]).to include('must be filled')
    end

    it 'validates price as integer (primitive type of MoneyCents) type' do
      result = CartSchema.call(
        reference: 'cart123',
        line_items: [
          { name: 'Item 1', price: "29.90", sku: 'SKU1' },
          { name: 'Item 2', price: "invalid_price", sku: 'SKU2' }
        ]
      )
      expect(result.errors[:line_items][1][:price]).to include('must be an integer')
    end
  end

  describe 'successful validation' do
    it 'validates a correct cart schema' do
      result = CartSchema.call(
        reference: 'cart123',
        line_items: [
          { name: 'Item 1', price: "29.90", sku: 'SKU1' },
          { name: 'Item 2', price: "39.90", sku: 'SKU2' }
        ]
      )
      expect(result).to be_success
      expect(result.to_h).to eq(
        reference: 'cart123',
        line_items: [
          { name: 'Item 1', price: 2990, sku: 'SKU1' },
          { name: 'Item 2', price: 3990, sku: 'SKU2' }
        ]
      )
    end
  end
end
