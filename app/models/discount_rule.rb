class DiscountRule < ApplicationRecord
  validates :prerequisite_skus, presence: true
  validates :eligible_skus, presence: true
  validates :discount_unit, presence: true
  validates :discount_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
