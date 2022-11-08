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

ActiveRecord::Schema[7.0].define(version: 2022_11_07_154930) do
  create_table "billing_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "member_id"
    t.string "description"
    t.date "reference_date"
    t.integer "invoice_id"
    t.string "status"
    t.integer "payable_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_cents"
    t.integer "quantity"
    t.string "billing_type", default: "general"
  end

  create_table "billings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "calendar_events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "external_id"
    t.string "title"
    t.string "status"
    t.text "external_url"
    t.text "description"
    t.string "location"
    t.timestamp "start_at"
    t.timestamp "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "processed", default: false
    t.integer "color_id"
    t.string "ical_id"
    t.boolean "reviewed", default: false
    t.index ["external_id"], name: "index_calendar_events_on_external_id"
  end

  create_table "coaches", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cel_number"
    t.string "alias"
    t.integer "pay_fixed"
    t.integer "pay_per_workout"
  end

  create_table "g_calendars", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "g_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token_type"
  end

  create_table "invoices", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "external_id"
    t.string "external_url"
    t.string "status"
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
  end

  create_table "members", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
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
  end

  create_table "members_workouts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "workout_id"
    t.integer "member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.integer "billing_item_id"
  end

  create_table "sync_tokens", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "workouts", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "coach_id"
    t.timestamp "start_at"
    t.timestamp "end_at"
    t.string "location"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "calendar_event_id"
    t.string "status", default: "confirmed"
    t.boolean "reviewed", default: false
    t.boolean "with_replacement", default: false
    t.integer "billing_item_id"
  end

end
