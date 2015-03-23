Spree::Core::Engine.routes.draw do
  match 'orders/return_authorizations/search', to: 'return_authorizations#search', via: [:get, :post]

  resources :orders do
    resources :return_authorizations, only: [:new, :create], shallow: true
  end

  namespace :admin do
   resource :return_requests_settings, only: [:edit, :update]
  end
end
