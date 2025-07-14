require 'rails_helper'

RSpec.describe DiscountRule, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:prerequisite_skus) }
    it { should validate_presence_of(:eligible_skus) }
    it { should validate_presence_of(:discount_unit) }
    it { should validate_presence_of(:discount_value) }
    it { should validate_numericality_of(:discount_value).is_greater_than_or_equal_to(0) }
  end
end
