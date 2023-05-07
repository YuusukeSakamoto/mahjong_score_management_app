Rails.application.routes.draw do
  devise_for :users
  
  resources :users
  resources :players do
    resources :rules
  end
  
  get '/', to: 'tops#show'
  
  get '/about', to: 'static_pages#about' 
  get '/contact', to: 'static_pages#contact' 
  
end
