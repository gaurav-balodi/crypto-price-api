require "test_helper"

class PricesControllerTest < ActionDispatch::IntegrationTest
  setup do
    Rails.cache.clear
  end

  test "returns crypto price" do
    serialized = CryptoPriceSerializer.new.serialize(crypto_prices(:bitcoin))

    PriceLookupService.stub(:call, serialized) do
      get "/prices/bitcoin"

      assert_response :success

      body = JSON.parse(response.body)

      assert body["success"]
      assert_equal "bitcoin", body["data"]["symbol"]
    end
  end

  test "returns not found when price does not exist" do
    PriceLookupService.stub(:call, nil) do
      symbol = "unknown"
      get "/prices/#{symbol}"

      assert_response :not_found

      body = JSON.parse(response.body)

      assert_not body["success"]
      assert_equal "No price found for '#{symbol}'", body["error"]["message"]
    end
  end

  test "normalizes symbol case through the real service (no stub)" do
    get "/prices/BITCOIN"

    assert_response :success

    body = JSON.parse(response.body)
    assert_equal "bitcoin", body["data"]["symbol"]
  end
end