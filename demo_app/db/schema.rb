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

ActiveRecord::Schema.define(version: 2021_07_10_220648) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aaas", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "aaas_bbbs", id: false, force: :cascade do |t|
    t.bigint "aaa_id", null: false
    t.bigint "bbb_id", null: false
  end

  create_table "alfas", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "bravo_id"
    t.index ["bravo_id"], name: "index_alfas_on_bravo_id"
  end

  create_table "bbbs", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "bravos", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "charlies", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "deltum_id", null: false
    t.index ["deltum_id"], name: "index_charlies_on_deltum_id"
  end

  create_table "delta", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "echos", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "foxtrot_id"
    t.index ["foxtrot_id"], name: "index_echos_on_foxtrot_id"
  end

  create_table "foxtrots", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "gophers", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "hotel_id"
    t.index ["hotel_id"], name: "index_gophers_on_hotel_id"
  end

  create_table "hotels", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "aaas_bbbs", "aaas"
  add_foreign_key "aaas_bbbs", "bbbs"
  add_foreign_key "alfas", "bravos"
  add_foreign_key "charlies", "delta"
  add_foreign_key "echos", "foxtrots"
  add_foreign_key "gophers", "hotels", on_delete: :nullify
end
