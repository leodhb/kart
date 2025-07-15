require 'rails_helper'

RSpec.describe DiscountRule, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:prerequisite_skus) }
    it { should validate_presence_of(:eligible_skus) }
    it { should validate_presence_of(:discount_unit) }
    it { should validate_presence_of(:discount_value) }
    it { should validate_numericality_of(:discount_value).is_greater_than_or_equal_to(0) }

    context 'when a discount rule already exists' do
      before { create(:discount_rule) }

      it 'is invalid' do
        rule = build(:discount_rule)
        expect(rule).not_to be_valid
        expect(rule.errors[:base]).to include('Only one discount rule can be created.')
      end
    end

    context 'when no discount rule exists' do
      it 'is valid' do
        rule = build(:discount_rule)
        expect(rule).to be_valid
      end
    end
  end
end
