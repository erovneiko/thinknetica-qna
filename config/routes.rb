Rails.application.routes.draw do
  devise_for :users

  resources :questions, except: :edit do
    resources :answers, shallow: true do
      put :best, on: :member
      put :vote_up, on: :member
      put :vote_down, on: :member
    end
    put :vote_up, on: :member
    put :vote_down, on: :member
  end

  resources :files, only: :destroy
  resources :links, only: :destroy

  root to: 'questions#index'
  get 'awards', to: 'awards#index'
end
