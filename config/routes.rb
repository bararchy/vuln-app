VulnerableApp::Application.routes.draw do
  # Swagger/OpenAPI Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Information disclosure endpoint
  get '/config', to: 'application#show_config'

  resources :posts

  resources :users
  resources :sessions, only: :create
end
