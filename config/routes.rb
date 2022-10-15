Rails.application.routes.draw do
  get 'billing/index'
  get 'billing/bill'
  resources :workouts
  resources :coaches
  resources :members
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
