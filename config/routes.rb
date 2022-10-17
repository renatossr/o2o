Rails.application.routes.draw do
  get 'admin/index'
  get 'billing/index'
  get 'billing/bill'

  get '/redirect', to: 'gcalendar#redirect', as: 'redirect'
  get '/callback', to: 'gcalendar#callback', as: 'callback'
  get '/calendars', to: 'gcalendar#calendars', as: 'calendars'
  get '/events/:calendar_id', to: 'gcalendar#events', as: 'events', calendar_id: /[^\/]+/

  resources :workouts
  resources :coaches
  resources :members
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
