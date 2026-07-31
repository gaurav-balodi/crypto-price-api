require "test_helper"

class CryptoPriceTest < ActiveSupport::TestCase
  setup do
    @crypto_price = crypto_prices(:bitcoin)
  end

  test "is valid" do
    assert @crypto_price.valid?
  end

  test "requires symbol" do
    @crypto_price.symbol = nil

    assert_not @crypto_price.valid?
  end

  test "requires unique symbol" do
    duplicate = crypto_prices(:bitcoin).dup

    assert_not duplicate.valid?
  end

  test "requires non negative price" do
    @crypto_price.price = -10

    assert_not @crypto_price.valid?
  end

  test "normalizes symbol" do
    @crypto_price.symbol = "  BITCOIN "

    @crypto_price.valid?

    assert_equal "bitcoin", @crypto_price.symbol
  end
end
