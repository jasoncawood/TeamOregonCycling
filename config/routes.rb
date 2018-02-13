Rails.application.routes.draw do
  devise_for :users

  root to: 'pages#show', id: 'about_us'

  resources :pages, only: %i[show]

  namespace :admin do
    resources :users
  end
end
