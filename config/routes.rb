Rails.application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  namespace :players do
    resources :searches, only: :index, defaults: { format: :json }
    resources :invitations, only: [:new]
    resources :authentications, only: :index
  end

  namespace :rules do
    resources :searches, only: [:index ,:show], defaults: { format: :json }
  end

  resources :players do
    resources :rules
  end

  namespace :matches do
    resources :calculates, only: :index, defaults: { format: :json }
    resources :switches, only: [:index]
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
  get '/me', to: 'users#show'
  resources :unsubscribes, only: [:index, :destroy]

  namespace :match_groups do
    resources :switches, only: [:index]
  end

  resources :match_groups, only: [:index, :show, :destroy] do
    resource :chip_results, only: [:edit, :update]
    resources :switches, only: [:index]
  end

  resources :leagues

  resources :questions, only: [:index]
  resources :terms, only: [:index]
  resources :privacies, only: [:index]
  root to: 'tops#show'

  # エラーハンドリング（本番環境用）
  get '*not_found' => 'application#routing_error'
  post '*not_found' => 'application#routing_error'

end