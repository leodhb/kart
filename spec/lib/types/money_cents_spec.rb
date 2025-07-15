require 'rails_helper'

RSpec.describe Types::MoneyCents, type: :type do
  describe '.call' do
    it 'converts a valid float to cents' do
      expect(Types::MoneyCents.call(10.99)).to eq(1099)
      expect(Types::MoneyCents.call(0.01)).to eq(1)
      expect(Types::MoneyCents.call(0.00)).to eq(0)
    end

    it 'converts a valid integer to cents' do
      expect(Types::MoneyCents.call(100)).to eq(10000)
    end

    it 'converts a string representation of a float to cents' do
      expect(Types::MoneyCents.call("10.99")).to eq(1099)
      expect(Types::MoneyCents.call("0.01")).to eq(1)
      expect(Types::MoneyCents.call("0.00")).to eq(0)
    end

    it 'handles negative amounts' do
      expect(Types::MoneyCents.call(-5.50)).to eq(-550)
    end

    it 'raises an error for invalid input' do
      expect { Types::MoneyCents.call("invalid") }.to raise_error(Dry::Types::CoercionError)
    end
  end
end
