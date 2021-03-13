Rails.application.routes.draw do
  devise_for :users

  resources :questions, except: :edit do
    resources :answers, shallow: true do
      put :best, on: :member
    end
  end

  root to: 'questions#index'
end
