Rails.application.routes.draw do
  get "calendar_event/index"
  get "calendar_event/process_events", as: "proc_events"
  get "/admin", to: "admin#index", as: "admin"
  get "billing/index", as: "billing"
  get "billing/bill"

  get "/redirect", to: "g_calendar#redirect", as: "redirect"
  get "/callback", to: "g_calendar#callback", as: "callback"
  get "/calendars", to: "g_calendar#calendars", as: "calendars"
  get "/events", to: "g_calendar#events", as: "events"
  get "/events/full", to: "g_calendar#eventsFullSync", as: "eventsFullSync"

  resources :workouts
  resources :coaches
  resources :members
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
