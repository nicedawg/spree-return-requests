Spree::Core::Engine.routes.draw do
  resources :return_requests

  namespace :admin do
    resource :return_requests_settings, only: [:edit, :update]
    resources :return_requests do
      member do
        put 'approve'
        put 'deny'
      end
    end
  end
end
