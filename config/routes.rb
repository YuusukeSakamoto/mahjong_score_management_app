Rails.application.routes.draw do
  
  namespace :players do 
    resources :searches, only: :index, defaults: { format: :json }
    resource :invitations, only: [:new]
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
  
  resources :matches, only: [:index, :show, :new, :edit, :create, :update, :destroy] do 
    resources :results, only: [:index] 
  end
  
  # devise_for :users
  devise_for :users, controllers: {
    :confirmations => 'users/confirmations',
    :registrations => 'users/registrations',
    :sessions => 'users/sessions',
    :passwords => 'users/passwords'
  }
  
  namespace :users do
    resource :invitations
  end
  resources :users
  
  root to: 'tops#show'
  
  get '/about', to: 'static_pages#about'  
  get '/contact', to: 'static_pages#contact' 
  
end
