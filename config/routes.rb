Rails.application.routes.draw do
  get "/prices/:symbol", to: "prices#show"

  match "*unmatched", to: "application#route_not_found", via: :all
end
