Rails.application.routes.draw do
  
  devise_for :users

  devise_scope :user do
    %i(event_promoter attendee).each do |role|
      get "#{role}s/sign_up", to: "registrations/#{role}s#new"
      post "#{role}s/sign_up", to: "registrations/#{role}s#create"
    end
  end
  
  resources :campaigns, only: [:new, :create, :show, :index] do
    member do
      resources :pledges, only: [:create]
    end
  end
  
  get '/pages', to: 'pages#home'
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root to: 'pages#show', id: 'home'
  
end
