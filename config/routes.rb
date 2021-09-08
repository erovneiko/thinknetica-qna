Rails.application.routes.draw do
  devise_for :users

  concern :votable do
    member do
      put :vote_up
      put :vote_down
    end
  end

  concern :commentable do
    resources :comments, only: [:new, :create]
  end

  resources :questions, except: :edit, concerns: [:votable, :commentable] do
    resources :answers, shallow: true, concerns: [:votable, :commentable] do
      put :best, on: :member
    end
  end

  resources :files, only: :destroy
  resources :links, only: :destroy
  resources :comments, only: [:index]

  get 'awards', to: 'awards#index'

  root to: 'questions#index'

  mount ActionCable.server => '/cable'
end
