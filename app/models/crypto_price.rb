class CryptoPrice < ApplicationRecord
  normalizes :symbol, with: ->(symbol) { symbol.to_s.downcase.strip }

  validates :symbol,
            presence: true,
            uniqueness: { case_sensitive: false }

  validates :price,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }

  validates :fetched_at,
            presence: true
end
