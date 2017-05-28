Rails.application.routes.draw do
  devise_for :users
  root to: 'candidates#index'

  resources :candidates

  get 'scrapers', to: 'scrapers#index'
  post 'scrapers/candidate_emails', to: 'scrapers#candidate_emails'
  post 'scrapers/verify_emails', to: 'scrapers#verify_emails'
end
