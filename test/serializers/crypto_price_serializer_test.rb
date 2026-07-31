require "test_helper"

class CryptoPriceSerializerTest < ActiveSupport::TestCase
  setup do
    @serializer = CryptoPriceSerializer.new
  end

  test "returns serialized crypto price" do
    crypto_price = crypto_prices(:bitcoin)

    assert_equal(
      {
        symbol: crypto_price.symbol,
        price: crypto_price.price,
        fetched_at: crypto_price.fetched_at
      },
      @serializer.serialize(crypto_price)
    )
  end

  test "returns nil for nil object" do
    assert_nil @serializer.serialize(nil)
  end
end
