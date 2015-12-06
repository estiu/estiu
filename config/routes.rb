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
      get 'create_event', to: 'events#new', as: 'new_event'
      post 'create_event', to: 'events#create', as: 'create_event'
      get ':invite_token', to: 'campaigns#show'
    end
  end
  
  resources :events, only: [:index, :show, :create] do
    member do
      post :submit_documents
      post :submit
      resources :event_documents, only: [:destroy], param: :event_document_id
    end
  end
  
  resources :venues, only: [:create]
  
  get '/pages', to: 'pages#home'
  get "/pages/*id" => 'pages#show', as: :page, format: false
  root to: 'application#home'
  
end
