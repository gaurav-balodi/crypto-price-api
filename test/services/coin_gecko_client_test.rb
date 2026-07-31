require "test_helper"

class CoinGeckoClientTest < ActiveSupport::TestCase
  test "raises error for blank symbol" do
    error = assert_raises(CoinGeckoClient::Error) do
      CoinGeckoClient.fetch_price(nil)
    end

    assert_equal "Symbol can't be blank.", error.message
  end

  test "raises MissingApiKeyError when API key is not configured" do
    CoinGeckoClient.stub(:api_key, nil) do
      error = assert_raises(CoinGeckoClient::MissingApiKeyError) do
        CoinGeckoClient.fetch_price("bitcoin")
      end

      assert_match(/not configured/i, error.message)
    end
  end

  test "sends the API key in the request header" do
    captured_request = nil

    CoinGeckoClient.stub(:perform_request, lambda { |uri|
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = CoinGeckoClient::USER_AGENT
      request[CoinGeckoClient::API_KEY_HEADER] = Rails.application.credentials.coingecko_api_key
      captured_request = request

      fake_response = Net::HTTPOK.new("1.1", "200", "OK")
      fake_response.instance_variable_set(:@body, '{"bitcoin":{"usd":63786.0}}')
      fake_response.instance_variable_set(:@read, true)
      fake_response
    }) do
      CoinGeckoClient.fetch_price("bitcoin")
    end

    assert_equal Rails.application.credentials.coingecko_api_key, captured_request[CoinGeckoClient::API_KEY_HEADER]
  end

  test "raises custom error when request times out" do
    CoinGeckoClient.stub(:perform_request, proc { raise Net::ReadTimeout }) do
      assert_raises(CoinGeckoClient::Error) do
        CoinGeckoClient.fetch_price("bitcoin")
      end
    end
  end

  test "returns price on successful response" do
    fake_response = Net::HTTPOK.new("1.1", "200", "OK")
    fake_response.instance_variable_set(:@body, '{"bitcoin":{"usd":63786.0}}')
    fake_response.instance_variable_set(:@read, true)

    CoinGeckoClient.stub(:perform_request, fake_response) do
      assert_equal 63786.0, CoinGeckoClient.fetch_price("bitcoin")
    end
  end

  test "raises error when unauthorized due to invalid API key" do
    fake_response = Net::HTTPUnauthorized.new("1.1", "401", "Unauthorized")

    CoinGeckoClient.stub(:perform_request, fake_response) do
      error = assert_raises(CoinGeckoClient::Error) do
        CoinGeckoClient.fetch_price("bitcoin")
      end

      assert_match(/invalid or unauthorized/i, error.message)
    end
  end

  test "raises error when rate limited" do
    fake_response = Net::HTTPTooManyRequests.new("1.1", "429", "Too Many Requests")

    CoinGeckoClient.stub(:perform_request, fake_response) do
      error = assert_raises(CoinGeckoClient::Error) do
        CoinGeckoClient.fetch_price("bitcoin")
      end

      assert_match(/rate limit/i, error.message)
    end
  end

  test "raises error when price not found for symbol" do
    fake_response = Net::HTTPOK.new("1.1", "200", "OK")
    fake_response.instance_variable_set(:@body, "{}")
    fake_response.instance_variable_set(:@read, true)

    CoinGeckoClient.stub(:perform_request, fake_response) do
      error = assert_raises(CoinGeckoClient::Error) do
        CoinGeckoClient.fetch_price("dogecoin")
      end

      assert_match(/not found/i, error.message)
    end
  end

  test "raises error for unexpected HTTP status" do
    fake_response = Net::HTTPInternalServerError.new("1.1", "500", "Internal Server Error")

    CoinGeckoClient.stub(:perform_request, fake_response) do
      error = assert_raises(CoinGeckoClient::Error) do
        CoinGeckoClient.fetch_price("bitcoin")
      end

      assert_match(/HTTP 500/, error.message)
    end
  end
end
