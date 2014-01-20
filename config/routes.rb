Spree::Core::Engine.routes.draw do
  resources :return_requests

  namespace :admin do
    resources :return_requests
  end
end
