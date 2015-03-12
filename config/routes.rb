Spree::Core::Engine.routes.draw do
  resources :return_requests

  resources :orders do
    resources :return_authorizations, only: [:new, :create], shallow: true
  end

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
