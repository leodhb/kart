require "dry-schema"

CartSchema = Dry::Schema.Params do
  required(:reference).filled(:string)

  required(:line_items).array(:hash) do
    required(:name).filled(:string)
    required(:price).filled(Types::MoneyCents)
    required(:sku).filled(:string)
  end
end
