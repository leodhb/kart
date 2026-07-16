class CreateDiscountRules < ActiveRecord::Migration[8.0]
  def change
    create_table :discount_rules do |t|
      t.jsonb :prerequisite_skus, null: false, default: [], array: true
      t.jsonb :eligible_skus, null: false, default: [], array: true
      t.string :discount_unit, null: false
      t.decimal :discount_value, null: false, precision: 10, scale: 2

      t.timestamps
    end
  end
end
