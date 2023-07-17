Rails.application.routes.draw do
  
  namespace :players do 
    resources :searches, only: :index, defaults: { format: :json }
    resources :invitations, only: [:index, :new]
  end  
  
  namespace :rules do 
    resources :searches, only: :index, defaults: { format: :json }
  end
  
  resources :players, only: [:show, :new, :create] do 
    resources :rules
  end
  
  namespace :matches do 
    resources :calculates, only: :index, defaults: { format: :json }
  end
  
  resources :matches do 
    resources :results, only: [:index] 
  end
  
  devise_for :users, controllers: {
    :confirmations => 'users/confirmations',
    :registrations => 'users/registrations',
    :sessions => 'users/sessions',
    :passwords => 'users/passwords'
  }
  
  resources :users  
  resources :match_groups, only: [:index, :show] do
    resource :chip_results, only: [:edit, :update]
  end  
  
  resources :leagues

  root to: 'tops#show'
  
end