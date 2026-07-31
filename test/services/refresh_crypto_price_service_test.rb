require "test_helper"

class RefreshCryptoPriceServiceTest < ActiveSupport::TestCase
  setup do
    Rails.cache.clear
  end

  test "creates a new crypto price when record does not exist" do
    CoinGeckoClient.stub(:fetch_price, 120000.55) do
      CryptoPrice.where(symbol: "dogecoin").delete_all

      result = RefreshCryptoPriceService.call("dogecoin")

      assert result[:success]

      crypto_price = CryptoPrice.find_by(symbol: "dogecoin")

      assert_not_nil crypto_price
      assert_equal 120000.55, crypto_price.price
    end
  end

  test "updates existing crypto price" do
    CoinGeckoClient.stub(:fetch_price, 125000.10) do
      RefreshCryptoPriceService.call("bitcoin")

      assert_equal(
        125000.10,
        crypto_prices(:bitcoin).reload.price
      )
    end
  end

  test "updates cache with the serialized crypto price after successful refresh" do
    CoinGeckoClient.stub(:fetch_price, 110500.25) do
      RefreshCryptoPriceService.call("bitcoin")

      cached = Rails.cache.read("crypto_price:bitcoin")
      expected = CryptoPriceSerializer.new.serialize(crypto_prices(:bitcoin).reload)

      assert_equal expected, cached
    end
  end

  test "returns failure when client raises error" do
    CoinGeckoClient.stub(
      :fetch_price,
      proc { raise CoinGeckoClient::Error, "API unavailable" }
    ) do
      result = RefreshCryptoPriceService.call("bitcoin")

      assert_not result[:success]
      assert_equal "API unavailable", result[:error]
    end
  end

  test "keeps previous price when api fails" do
    previous_price = crypto_prices(:bitcoin).price

    CoinGeckoClient.stub(
      :fetch_price,
      proc { raise CoinGeckoClient::Error, "API unavailable" }
    ) do
      RefreshCryptoPriceService.call("bitcoin")
    end

    assert_equal previous_price, crypto_prices(:bitcoin).reload.price
  end

  test "returns failure and keeps previous price when fetched price fails model validation" do
    previous_price = crypto_prices(:bitcoin).price

    CoinGeckoClient.stub(:fetch_price, -50.0) do
      result = RefreshCryptoPriceService.call("bitcoin")

      assert_not result[:success]
      assert_match(/price/i, result[:error])
    end

    assert_equal previous_price, crypto_prices(:bitcoin).reload.price
  end
end
