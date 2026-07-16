require "dry-types"

module Types
  include Dry.Types()

  MoneyCents = Types.Constructor(Integer) do |input|
    Money.float_to_cents(input)
  end
end
