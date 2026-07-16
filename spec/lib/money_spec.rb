require 'rails_helper'

RSpec.describe Money, type: :lib do
  describe '.float_to_cents' do
    it 'converts a float to cents' do
      expect(Money.float_to_cents(10.99)).to eq(1099)
      expect(Money.float_to_cents(0.01)).to eq(1)
      expect(Money.float_to_cents(0.00)).to eq(0)
    end

    it 'handles negative amounts' do
      expect(Money.float_to_cents(-5.50)).to eq(-550)
    end
  end

  describe '.format_cents' do
    it 'formats cents as a string with two decimal places' do
      expect(Money.format_cents(1099)).to eq('10.99')
      expect(Money.format_cents(1)).to eq('0.01')
      expect(Money.format_cents(0)).to eq('0.00')
    end

    it 'handles negative cents' do
      expect(Money.format_cents(-550)).to eq('-5.50')
    end
  end
end
