Rails.application.routes.draw do
  devise_for :users

  concern :votable do
    member do
      put :vote_up
      put :vote_down
    end
  end

  resources :questions, except: :edit, concerns: :votable do
    resources :answers, shallow: true, concerns: :votable do
      put :best, on: :member
    end
  end

  resources :files, only: :destroy
  resources :links, only: :destroy

  get 'awards', to: 'awards#index'

  root to: 'questions#index'
end
