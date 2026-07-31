require "json"
require "net/http"
require "uri"

class CoinGeckoClient
  BASE_URL = "https://api.coingecko.com/api/v3/simple/price".freeze
  API_KEY_HEADER = "x-cg-demo-api-key".freeze

  USER_AGENT = "CryptoPriceApi/1.0".freeze

  OPEN_TIMEOUT = 5
  READ_TIMEOUT = 5

  class Error < StandardError; end
  class MissingApiKeyError < Error; end

  class << self
    def fetch_price(symbol)
      raise Error, "Symbol can't be blank." if symbol.blank?
      raise MissingApiKeyError, "CoinGecko API key is not configured." if api_key.blank?

      response = perform_request(build_uri(symbol))
      extract_price(response, symbol)
    rescue JSON::ParserError,
           SocketError,
           Net::OpenTimeout,
           Net::ReadTimeout,
           Errno::ECONNREFUSED,
           EOFError,
           IOError => e
      raise Error, "Failed to fetch '#{symbol}' price: #{e.message}"
    end

    private

    def api_key
      Rails.application.credentials.coingecko_api_key
    end

    def build_uri(symbol)
      uri = URI(BASE_URL)
      uri.query = URI.encode_www_form(
        ids: symbol,
        vs_currencies: "usd"
      )
      uri
    end

    def perform_request(uri)
      request = Net::HTTP::Get.new(uri)
      request["User-Agent"] = USER_AGENT
      request[API_KEY_HEADER] = api_key

      Net::HTTP.start(
        uri.host,
        uri.port,
        use_ssl: true,
        open_timeout: OPEN_TIMEOUT,
        read_timeout: READ_TIMEOUT
      ) do |http|
        http.request(request)
      end
    end

    def extract_price(response, symbol)
      case response
      when Net::HTTPSuccess
        parse_success_response(response.body, symbol)
      when Net::HTTPUnauthorized, Net::HTTPForbidden
        raise Error, "CoinGecko API key is invalid or unauthorized."
      when Net::HTTPTooManyRequests
        raise Error, "CoinGecko API rate limit exceeded."
      else
        raise Error, "CoinGecko API returned HTTP #{response.code}."
      end
    end

    def parse_success_response(body, symbol)
      payload = JSON.parse(body)

      payload.fetch(symbol).fetch("usd")
    rescue KeyError
      raise Error, "Price not found for '#{symbol}'."
    end
  end
end
