Rails.application.routes.draw do
  devise_for :users
  
  get '/users', to: 'users#index'
  get '/users/:id', to: 'users#show'
  
  get '/', to: 'tops#show' 
  
  # get '/help', to: 'static_pages#help' 
  get '/about', to: 'static_pages#about' 
  get '/contact', to: 'static_pages#contact' 
  
  resources :groups
  
end
