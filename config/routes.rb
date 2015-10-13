Rails.application.routes.draw do
  
  devise_for :users, controllers: {registrations: 'registrations'}

  devise_scope :user do
    get 'event_promoters/sign_up', to: 'event_promoter_registrations#new'
    post 'event_promoters/sign_up', to: 'event_promoter_registrations#create'
  end

  resources :campaigns, only: [:new, :create, :show, :index]
  
  get '/pages', to: 'pages#home'
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root to: 'pages#show', id: 'home'
  
end
