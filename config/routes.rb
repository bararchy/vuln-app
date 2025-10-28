VulnerableApp::Application.routes.draw do
  # Swagger/OpenAPI Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  resources :posts

  resources :users
  resources :sessions, only: :create
end
