# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 1) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "apis", force: :cascade do |t|
    t.integer  "client_id",   null: false
    t.string   "name",        null: false
    t.string   "system_name", null: false
    t.string   "public_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apis", ["public_key"], name: "index_apis_on_public_key", unique: true, using: :btree
  add_index "apis", ["system_name"], name: "index_apis_on_system_name", unique: true, using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "email",         null: false
    t.string   "password_hash", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "clients", ["email"], name: "index_clients_on_email", unique: true, using: :btree

  create_table "collections", force: :cascade do |t|
    t.integer  "api_id",      null: false
    t.string   "name",        null: false
    t.string   "system_name", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "collections", ["name"], name: "index_collections_on_name", using: :btree
  add_index "collections", ["system_name"], name: "index_collections_on_system_name", using: :btree

  create_table "fields", force: :cascade do |t|
    t.integer "collection_id",              null: false
    t.string  "name",                       null: false
    t.string  "type",                       null: false
    t.text    "validations",   default: [],              array: true
  end

  create_table "private_keys", force: :cascade do |t|
    t.integer  "api_id",     null: false
    t.string   "secret",     null: false
    t.datetime "created_at", null: false
  end

  add_index "private_keys", ["secret"], name: "index_private_keys_on_secret", unique: true, using: :btree

  create_table "records", force: :cascade do |t|
    t.integer  "api_id",        null: false
    t.integer  "collection_id", null: false
    t.hstore   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "records", ["api_id", "collection_id"], name: "index_records_on_api_id_and_collection_id", using: :btree
  add_index "records", ["data"], name: "index_records_on_data", using: :gin

  create_table "smart_requests", force: :cascade do |t|
    t.integer  "status",                    null: false
    t.inet     "ip",                        null: false
    t.hstore   "geolocation"
    t.string   "browser"
    t.string   "platform"
    t.datetime "started_at",                null: false
    t.datetime "ended_at",                  null: false
    t.decimal  "duration",    precision: 3
  end

  create_table "tier_usages", force: :cascade do |t|
    t.integer  "tier_id",        null: false
    t.integer  "api_id",         null: false
    t.datetime "created_at",     null: false
    t.datetime "deactivated_at"
  end

  create_table "tiers", force: :cascade do |t|
    t.string  "name",                                 null: false
    t.string  "system_name",                          null: false
    t.integer "quota",                                null: false
    t.decimal "price",       precision: 15, scale: 2, null: false
  end

end
