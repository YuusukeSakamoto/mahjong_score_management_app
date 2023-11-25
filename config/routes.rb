Rails.application.routes.draw do
  
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  namespace :players do 
    resources :searches, only: :index, defaults: { format: :json }
    resources :invitations, only: [:index, :new]
    resources :authentications, only: :index
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
    :passwords => 'users/passwords' # passwordリセット
  }
  resources :users, only: [:show]
  resources :unsubscribes, only: [:index, :destroy]
  
  resources :match_groups, only: [:index, :show, :destroy] do
    resource :chip_results, only: [:edit, :update]
  end  
  
  resources :leagues
  
  resources :contacts, only: [:new, :create]

  root to: 'tops#show'
  
end