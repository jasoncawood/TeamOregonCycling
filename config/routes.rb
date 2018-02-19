Rails.application.routes.draw do
  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    passwords: 'users/passwords',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    unlocks: 'users/unlocks',
    # omniauth_callbacks: 'users/omniauth_callbacks'
  }

  root to: 'pages#show', id: 'about_us'

  resources :pages, only: %i[show]

  resources :memberships

  namespace :admin do
    resources :users
  end
end
