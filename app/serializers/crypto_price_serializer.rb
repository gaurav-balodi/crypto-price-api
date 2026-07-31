class CryptoPriceSerializer
  def serialize(crypto_price)
    return nil if crypto_price.nil?

    {
      symbol: crypto_price.symbol,
      price: crypto_price.price,
      fetched_at: crypto_price.fetched_at
    }
  end
end
