Rails.application.routes.draw do
  devise_for :users, controllers: { invitations: "users/invitations" }

  post "iugu/invoice_status_webhook"
  root "members#index"

  get "/admin/settings", to: "admin#settings", as: "settings"
  get "/admin/user_management", to: "admin#user_management", as: "user_management"

  get "calendar_event/index"
  get "calendar_event/process_events(/:id)", to: "calendar_event#process_events", as: "proc_events"
  patch "calendar_event/process_events(/:id)", to: "calendar_event#update", as: "update_event"
  patch "calendar_event/confirm(/:id)", to: "calendar_event#confirm", as: "confirm_event"

  get "/redirect", to: "g_calendar#redirect", as: "redirect"
  get "/callback", to: "g_calendar#callback", as: "callback"
  get "/events", to: "g_calendar#events", as: "events"
  get "/events/full", to: "g_calendar#eventsFullSync", as: "eventsFullSync"

  post "items_import/import_members"
  post "items_import/import_coaches"

  resources :billings do
    post :start_cycle, on: :collection, as: :start_cycle
    post :close_cycle, on: :member, as: :close_cycle
    get :dashboard, on: :collection
  end

  resources :workouts
  resources :coaches
  resources :members

  resources :payables do
    patch :confirm, on: :collection, as: :confirm
    patch :cancel, on: :member, as: :cancel
    get :new_from_workout, on: :collection
  end

  resources :invoices do
    patch :confirm_all, on: :collection, as: :confirm_all
    patch :confirm, on: :member, as: :confirm
    patch :cancel, on: :member, as: :cancel
    get :new_from_workout, on: :collection
  end
end
