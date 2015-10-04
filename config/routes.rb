Rails.application.routes.draw do
  
  resources :campaigns, only: [:new, :create, :show, :index]
  
  get '/pages', to: redirect('/')
  
end
