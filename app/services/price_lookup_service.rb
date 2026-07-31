class PriceLookupService
  def self.call(...)
    new(...).call
  end

  def initialize(symbol)
    @symbol = symbol.to_s.downcase.strip
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: CRYPTO_PRICE_CACHE_EXPIRY, skip_nil: true) do
      crypto_price = CryptoPrice.find_by(symbol: symbol)

      CryptoPriceSerializer.new.serialize(crypto_price) if crypto_price.present?
    end
  end

  private

  attr_reader :symbol

  def cache_key
    "crypto_price:#{symbol}"
  end
end
