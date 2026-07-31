class PricesController < ApplicationController
  def show
    crypto_price = PriceLookupService.call(params[:symbol])

    if crypto_price.present?
      render_success(
        crypto_price,
      )
    else
      render_error(
        "No price found for '#{params[:symbol]}'",
      	status: :not_found,
      )
    end
  end
end
