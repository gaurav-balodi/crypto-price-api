require "test_helper"

class PriceLookupServiceTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  test "returns serialized crypto price" do
    expected = CryptoPriceSerializer.new.serialize(
      crypto_prices(:bitcoin)
    )

    assert_equal expected, PriceLookupService.call("bitcoin")
  end

  test "returns nil for unknown symbol" do
    assert_nil PriceLookupService.call("unknown")
  end

  test "only queries the database once across repeated lookups" do
    call_count = 0
    original_find_by = CryptoPrice.method(:find_by)

    CryptoPrice.stub(:find_by, lambda { |*args|
      call_count += 1
      original_find_by.call(*args)
    }) do
      PriceLookupService.call("bitcoin")
      PriceLookupService.call("bitcoin")
    end

    assert_equal 1, call_count
  end

  test "does not cache a not-found result, so a later refresh is picked up immediately" do
    CryptoPrice.where(symbol: "dogecoin").delete_all

    assert_nil PriceLookupService.call("dogecoin")

    CryptoPrice.create!(symbol: "dogecoin", price: 0.42, fetched_at: Time.current)

    expected = CryptoPriceSerializer.new.serialize(CryptoPrice.find_by(symbol: "dogecoin"))

    assert_equal expected, PriceLookupService.call("dogecoin")
  end
end
