Rails.application.routes.draw do
  use_doorkeeper

  devise_for :users, controllers: { omniauth_callbacks: 'oauth_callbacks' }
  devise_scope :user do
    post 'user/enter_email', to: 'oauth_callbacks#enter_email'
  end

  root to: 'questions#index'

  concern :votable do
    member do
      put :vote_up
      put :vote_down
    end
  end

  concern :commentable do
    resources :comments, only: %i[new create]
  end

  resources :questions, except: :edit, concerns: %i[votable commentable] do
    resources :answers, shallow: true, concerns: %i[votable commentable] do
      put :best, on: :member
    end
  end

  resources :files, only: :destroy
  resources :links, only: :destroy
  resources :comments, only: :index

  get 'awards', to: 'awards#index'

  mount ActionCable.server => '/cable'

  namespace :api do
    namespace :v1 do
      resources :profiles, only: [] do
        get :me, on: :collection
        get :all, on: :collection
      end
      resources :questions, except: %i[new edit] do
        resources :answers, shallow: true, except: %i[index new edit]
      end
    end
  end
end
