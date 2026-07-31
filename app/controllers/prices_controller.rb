class PricesController < ApplicationController
  def show
    crypto_price = PriceLookupService.call(params[:symbol])

    if crypto_price.present?
      render_success(
        crypto_price,
      )
    else
      render_error(
      	"Price not found",
      	status: :not_found,
      )
    end
  end
end
