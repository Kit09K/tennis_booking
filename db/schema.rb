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

ActiveRecord::Schema[8.1].define(version: 2026_08_03_033350) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.string "account_number"
    t.bigint "cord_id", null: false
    t.datetime "created_at", null: false
    t.datetime "end_time"
    t.string "name_account"
    t.datetime "start_time"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["cord_id"], name: "index_bookings_on_cord_id"
    t.index ["user_id"], name: "index_bookings_on_user_id"
  end

  create_table "cancles", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_cancles_on_booking_id"
  end

  create_table "cords", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "location"
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bookings", "cords"
  add_foreign_key "bookings", "users"
  add_foreign_key "cancles", "bookings"
end
