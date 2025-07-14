class DiscountRule < ApplicationRecord
  validate :singleton_rule, on: :create

  validates :prerequisite_skus, presence: true
  validates :eligible_skus, presence: true
  validates :discount_unit, presence: true
  validates :discount_value, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def self.current
    first
  end

  def singleton_rule
    if DiscountRule.exists?
      errors.add(:base, "Only one discount rule can be created.")
    end
  end
end
