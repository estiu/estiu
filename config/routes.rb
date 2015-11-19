Rails.application.routes.draw do
  
  devise_for :users, controllers: {sessions: "sessions", omniauth_callbacks: "omniauth_callbacks"}

  devise_scope :user do
    %i(event_promoter attendee).each do |role|
      get "#{role}s/sign_up", to: "registrations/#{role}s#new"
      post "#{role}s/sign_up", to: "registrations/#{role}s#create"
    end
  end
  
  resources :campaigns, only: [:new, :create, :show, :index] do
    collection do
      get :mine
    end
    member do
      resources :pledges, only: [:create, :update], param: :pledge_id
      get 'create_event', to: 'events#new'
    end
  end
  
  resources :events, only: [:index, :show, :create]
  
  resources :venues, only: [:create]
  
  get '/pages', to: 'pages#home'
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root to: 'application#home'
  
end
