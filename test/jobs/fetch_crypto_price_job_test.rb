# frozen_string_literal: true

require "test_helper"

class FetchCryptoPriceJobTest < ActiveJob::TestCase
  test "delegates refresh to service" do
    called = false

    RefreshCryptoPriceService.stub(:call, lambda { |_symbol|
      called = true
      { success: true }
    }) do
      FetchCryptoPriceJob.perform_now("bitcoin")
    end

    assert called
  end
end
