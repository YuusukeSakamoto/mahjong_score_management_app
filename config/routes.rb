Rails.application.routes.draw do
  
  namespace :players do 
    resources :searches, only: :index, defaults: { format: :json }
  end  
  
  namespace :rules do 
    resources :searches, only: :index, defaults: { format: :json }
  end
  
  resources :players do
    resources :rules
  end
  
  get '/matches/calculates', to: 'matches/calculates#index', defaults: { format: :json } # pt計算json用
  
  
  resources :matches, only: [:show, :new, :create, :update, :destroy] do 
    resources :results, only: [:index] 
  end
  
  resources :results
  
  devise_for :users
  resources :users
  
  get '/', to: 'tops#show'
  
  get '/about', to: 'static_pages#about' 
  get '/contact', to: 'static_pages#contact' 
  
end
