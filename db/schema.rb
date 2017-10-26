# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171026010511) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: :cascade do |t|
    t.text     "comment"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "results", force: :cascade do |t|
    t.text     "request"
    t.text     "response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "trip_id"
    t.index ["trip_id"], name: "index_results_on_trip_id", using: :btree
  end

  create_table "tests", force: :cascade do |t|
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "group_id"
    t.index ["group_id"], name: "index_tests_on_group_id", using: :btree
  end

  create_table "trips", force: :cascade do |t|
    t.text     "origin"
    t.text     "destination"
    t.datetime "time"
    t.boolean  "arrive_by"
    t.string   "request_url"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "group_id"
    t.decimal  "origin_lat"
    t.decimal  "origin_lng"
    t.decimal  "destination_lat"
    t.decimal  "destination_lng"
    t.index ["group_id"], name: "index_trips_on_group_id", using: :btree
  end

end
