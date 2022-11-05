Rails.application.routes.draw do
  post "iugu/invoice_status_webhook"
  root "members#index"

  get "/admin", to: "admin#index", as: "admin"

  get "calendar_event/index"
  get "calendar_event/process_events(/:id)", to: "calendar_event#process_events", as: "proc_events"
  patch "calendar_event/process_events(/:id)", to: "calendar_event#update", as: "update_event"
  patch "calendar_event/confirm(/:id)", to: "calendar_event#confirm", as: "confirm_event"

  get "/redirect", to: "g_calendar#redirect", as: "redirect"
  get "/callback", to: "g_calendar#callback", as: "callback"
  get "/events", to: "g_calendar#events", as: "events"
  get "/events/full", to: "g_calendar#eventsFullSync", as: "eventsFullSync"

  get "billing/dashboard", as: "billing_dashboard"
  get "billing/billing_cycle", as: "billing_cycle"
  post "billing/start_cycle", as: "start_cycle"
  resources :billing do
    post :start_cycle, on: :member, as: :start_cycle
  end

  resources :workouts
  resources :coaches
  resources :members

  resources :invoices do
    patch :confirm, on: :collection, as: :confirm
    patch :cancel, on: :member, as: :cancel
  end
end
