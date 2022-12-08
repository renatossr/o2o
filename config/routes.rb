Rails.application.routes.draw do
  devise_for :users, skip: [:registrations], controllers: { invitations: "users/invitations" }
  as :user do
    get "users/edit" => "users/registrations#edit", :as => "edit_user_profile"
    patch "users/edit" => "users/registrations#update", :as => "user_profile"
    put "users/edit" => "users/registrations#update"
  end

  post "iugu/invoice_status_webhook"
  root "members#index"

  get "admin/settings", to: "admin#settings", as: "settings"
  get "admin/user_management", to: "admin#user_management", as: "user_management"

  delete "admin/users/:id" => "admin#destroy_user", :as => "destroy_user_registration"
  get "admin/users/:id/edit" => "admin#edit_user", :as => "edit_user_registration"
  patch "admin/users/:id/edit" => "admin#update_user", :as => "user_registration"
  put "admin/users/:id/edit" => "admin#update_user"

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
    patch :cancel_and_mirror, on: :member, as: :cancel_and_mirror
    get :new_from_workout, on: :collection
    get :ready_to_send, on: :collection
  end
end
