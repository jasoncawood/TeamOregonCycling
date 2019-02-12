Rails.application.routes.draw do
  root to: 'pages#show', id: 'about_us'

  resource :session, only: %i[new create destroy]
  resources :pages, only: %i[show]

  get '/contact_us', to: 'contact#new', as: :new_contact
  post '/contact_us', to: 'contact#create', as: :contact

  namespace :admin do
    resources :memberships, only: %i[create edit update destroy]
    resources :users do
      resources :memberships, only: %i[new index]
    end

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
