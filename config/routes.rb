Rails.application.routes.draw do
  
  devise_for :users
  resources :campaigns, only: [:new, :create, :show, :index]
  
  get '/pages', to: redirect('/')
  
end
