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
    resources :membership_types do
      member do
        post :undelete
      end
      collection do
        get 'deleted'
      end
    end
  end
end
