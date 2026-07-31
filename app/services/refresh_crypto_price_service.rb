class RefreshCryptoPriceService
  class << self
    def call(...)
      new(...).call
    end
  end

  def initialize(symbol)
    @symbol = symbol.to_s.downcase.strip
  end

  def call
    latest_price = CoinGeckoClient.fetch_price(symbol)

    crypto_price = CryptoPrice.find_or_initialize_by(symbol: symbol)
    crypto_price.update!(price: latest_price, fetched_at: Time.current)

    write_cache(crypto_price)

    success(crypto_price)
  rescue CoinGeckoClient::Error => e
    Rails.logger.error("CoinGecko API Error: #{e.message}")

    # Don't overwrite the existing record.
    # Continue serving the last known price.
    failure(e.message)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Failed to save crypto price: #{e.message}")

    failure(e.record.errors.full_messages.to_sentence)
  end

  private

  attr_reader :symbol

  def write_cache(crypto_price)
    Rails.cache.write(
      cache_key,
      CryptoPriceSerializer.new.serialize(crypto_price),
      expires_in: CRYPTO_PRICE_CACHE_EXPIRY
    )
  end

  def cache_key
    "crypto_price:#{symbol}"
  end

  def success(crypto_price)
    {
      success: true,
      crypto_price: crypto_price
    }
  end

  def failure(message)
    {
      success: false,
      error: message
    }
  end
end
