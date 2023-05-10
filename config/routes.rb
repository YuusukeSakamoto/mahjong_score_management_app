Rails.application.routes.draw do
  
  resources :players do
    resources :rules
  end
  
  devise_for :users

  resources :users

  
  get '/', to: 'tops#show'
  
  get '/about', to: 'static_pages#about' 
  get '/contact', to: 'static_pages#contact' 
  
end
