Rails.application.routes.draw do
  root "members#index"

  get "calendar_event/index"
  get "calendar_event/process_events(/:id)", to: "calendar_event#process_events", as: "proc_events"
  patch "calendar_event/process_events(/:id)", to: "calendar_event#update", as: "update_event"
  patch "calendar_event/confirm(/:id)", to: "calendar_event#confirm", as: "confirm_event"

  get "/admin", to: "admin#index", as: "admin"
  get "billing/dashboard", as: "billing_dashboard"
  get "billing/bill"
  get "billing/billing_cycle", as: "billing_cycle"
  post "billing/start_cycle", as: "start_cycle"
  get "billing/invoice(/:id)", to: "billing#show", as: "show_invoice"
  get "billing/invoice(/:id)/edit", to: "billing#edit", as: "edit_invoice"
  patch "billing/invoice(/:id)", to: "billing#update", as: "update_invoice"

  get "/redirect", to: "g_calendar#redirect", as: "redirect"
  get "/callback", to: "g_calendar#callback", as: "callback"
  get "/events", to: "g_calendar#events", as: "events"
  get "/events/full", to: "g_calendar#eventsFullSync", as: "eventsFullSync"

  resources :workouts
  resources :coaches
  resources :members
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
