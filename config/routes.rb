VulnerableApp::Application.routes.draw do
  # Swagger/OpenAPI Documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  # Information disclosure endpoint
  get '/config', to: 'application#show_config'

  resources :posts do
    collection do
      post 'render_html'
    end
  end

  resources :users do
    member do
      get 'credentials'
      post 'transfer_ownership'
    end
  end
  
  resources :sessions, only: :create
end
