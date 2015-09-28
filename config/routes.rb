Rails.application.routes.draw do
  
  get '/pages', to: redirect('/')
  
end
