Rails.application.routes.draw do
  
  resources :players do
    resources :rules
  end
  
  resources :results
  
  resources :matchs, only: [:show] do #showのみ
    resources :results, except: [:index] #index以外
  end
  
  
  devise_for :users
  resources :users
  
  get '/', to: 'tops#show'
  
  get '/about', to: 'static_pages#about' 
  get '/contact', to: 'static_pages#contact' 
  
end
