module Money
  def self.float_to_cents(amount)
    (BigDecimal(amount.to_s) * 100).round.to_i
  end

  def self.format_cents(cents)
    format("%.2f", cents.to_f / 100)
  end
end
