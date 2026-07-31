class FetchCryptoPriceJob < ApplicationJob
  queue_as :default

  def perform(symbol)
    RefreshCryptoPriceService.call(symbol)
  end
end
