# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_12_07_173634) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "billing_items", force: :cascade do |t|
    t.integer "member_id"
    t.string "description"
    t.date "reference_date"
    t.integer "invoice_id"
    t.integer "status", default: 0
    t.integer "payable_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents"
    t.integer "quantity"
    t.string "billing_type", default: "general"
  end

  create_table "billings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "reference_date"
    t.integer "status", default: 0
    t.integer "revenue_cents"
    t.integer "cost_cents"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.string "external_id"
    t.string "title"
    t.string "status"
    t.text "external_url"
    t.text "description"
    t.string "location"
    t.datetime "start_at", precision: nil
    t.datetime "end_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "processed", default: false
    t.integer "color_id"
    t.string "ical_id"
    t.boolean "reviewed", default: false
    t.index ["external_id"], name: "index_calendar_events_on_external_id"
  end

  create_table "coaches", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cel_number"
    t.string "alias"
    t.integer "pay_fixed"
    t.integer "pay_per_workout"
  end

  create_table "g_calendars", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "g_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token_type"
  end

  create_table "invoices", force: :cascade do |t|
    t.string "external_id"
    t.string "external_url"
    t.integer "status", default: 0
    t.date "reference_date"
    t.integer "member_id"
    t.integer "total_value_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "paid_at"
    t.integer "discount_cents", default: 0
    t.string "payment_method"
    t.integer "paid_cents"
    t.string "invoice_type"
    t.date "due_date"
    t.integer "billing_id"
  end

  create_table "members", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "alias"
    t.string "cel_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subscription_price"
    t.integer "class_price"
    t.boolean "active", default: true
    t.integer "responsible_id"
    t.integer "monday"
    t.integer "tuesday"
    t.integer "wednesday"
    t.integer "thursday"
    t.integer "friday"
    t.integer "saturday"
    t.integer "sunday"
    t.integer "replacement_classes", default: 0
    t.boolean "loyal", default: false
    t.integer "double_class_price"
    t.integer "triple_class_price"
    t.integer "subscription_type", default: 1
  end

  create_table "members_workouts", force: :cascade do |t|
    t.integer "workout_id"
    t.integer "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status"
    t.integer "billing_item_id"
    t.index ["member_id"], name: "index_members_workouts_on_member_id"
    t.index ["workout_id"], name: "index_members_workouts_on_workout_id"
  end

  create_table "payable_items", force: :cascade do |t|
    t.integer "coach_id"
    t.string "description"
    t.integer "price_cents"
    t.integer "quantity"
    t.integer "value_cents"
    t.integer "payable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "reference_date"
    t.string "payable_type"
  end

  create_table "payables", force: :cascade do |t|
    t.integer "coach_id"
    t.date "reference_date"
    t.integer "total_value_cents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.integer "discount_cents", default: 0
    t.string "payable_type"
    t.integer "billing_id"
  end

  create_table "sync_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["invitation_token"], name: "index_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "index_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "workouts", force: :cascade do |t|
    t.integer "coach_id"
    t.datetime "start_at", precision: nil
    t.datetime "end_at", precision: nil
    t.string "location"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "calendar_event_id"
    t.string "status", default: "confirmed"
    t.boolean "reviewed", default: false
    t.boolean "with_replacement", default: false
    t.integer "billing_item_id"
    t.integer "payable_item_id"
    t.boolean "cancelled", default: false
    t.boolean "gympass", default: false
    t.index ["calendar_event_id"], name: "index_workouts_on_calendar_event_id"
  end

end
