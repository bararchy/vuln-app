VulnerableApp::Application.routes.draw do
  resources :posts

  resources :users
  resources :sessions, only: :create
end
