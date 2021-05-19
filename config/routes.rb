Rails.application.routes.draw do
  devise_for :users

  resources :questions, except: :edit do
    resources :answers, shallow: true do
      put :best, on: :member
    end
  end

  delete '/questions/files/:id', to: 'questions#delete_file', as: 'questions_file'
  delete '/answers/files/:id', to: 'answers#delete_file', as: 'answers_file'

  root to: 'questions#index'
end
