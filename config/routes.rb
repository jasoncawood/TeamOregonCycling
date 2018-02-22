Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks',
  }

  root to: 'pages#show', id: 'about_us'

  resources :pages, only: %i[show]

  namespace :admin do
    resources :users
  end
end
