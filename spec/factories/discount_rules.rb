FactoryBot.define do
  factory :discount_rule do
    prerequisite_skus { ["SKU-P1", "SKU-P2", "SKU-P3"] }
    eligible_skus { ["SKU-E4", "SKU-E5", "SKU-E6"] }
    discount_unit { "percentage" }
    discount_value { 9.99 }
  end
end
