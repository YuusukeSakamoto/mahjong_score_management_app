Rails.application.routes.draw do
  
  resources :players do
    resources :rules
  end
  
  
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
