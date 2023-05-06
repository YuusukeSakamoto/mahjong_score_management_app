Rails.application.routes.draw do
  devise_for :users
  
  resources :users
  resources :groups
  # get '/users', to: 'users#index'
  # get '/users/:id', to: 'users#show'
  
  get '/', to: 'tops#show'
  
  get '/about', to: 'static_pages#about' 
  get '/contact', to: 'static_pages#contact' 
  
end
