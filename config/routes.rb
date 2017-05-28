Rails.application.routes.draw do
  root to: 'candidates#index'

  resources :candidates

  get 'scrapers', to: 'scrapers#index'
  get 'scrapers/candidate_emails', to: 'scrapers#candidate_emails'
end
