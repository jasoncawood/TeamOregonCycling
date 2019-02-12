Rails.application.routes.draw do
  root to: 'pages#show', id: 'about_us'

  resource :session, only: %i[new create destroy]

  get 'email_confirmation', to: 'sessions#email_confirmation_form'
  post 'email_confirmation', to: 'sessions#email_confirmation'
  get 'email_confirmation_token', to: 'sessions#send_new_email_confirmation_form'
  post 'email_confirmation_token', to: 'sessions#send_new_email_confirmation'

  resource :user
  resources :pages, only: %i[show]

  get '/contact_us', to: 'contact#new', as: :new_contact
  post '/contact_us', to: 'contact#create', as: :contact

  get '/email_confirmation',
      to: 'email_confirmation#show_form',
      as: :request_email_confirmation

  post '/email_confirmation',
       to: 'email_confirmation#confirm'

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
