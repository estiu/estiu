Rails.application.routes.draw do
  
  devise_for :users
  resources :campaigns, only: [:new, :create, :show, :index]
  
  get '/pages', to: 'pages#home'
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root to: 'pages#show', id: 'home'
  
end
