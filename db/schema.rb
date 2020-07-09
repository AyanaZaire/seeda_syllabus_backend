# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_18_155521) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "concentration_keywords", force: :cascade do |t|
    t.bigint "concentration_id", null: false
    t.bigint "keyword_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["concentration_id"], name: "index_concentration_keywords_on_concentration_id"
    t.index ["keyword_id"], name: "index_concentration_keywords_on_keyword_id"
  end

  create_table "concentrations", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.bigint "syllabus_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["syllabus_id"], name: "index_concentrations_on_syllabus_id"
  end

  create_table "keywords", force: :cascade do |t|
    t.string "word"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "syllabuses", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.string "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "category_id", null: false
    t.index ["category_id"], name: "index_syllabuses_on_category_id"
  end

  add_foreign_key "concentration_keywords", "concentrations"
  add_foreign_key "concentration_keywords", "keywords"
  add_foreign_key "concentrations", "syllabuses"
  add_foreign_key "syllabuses", "categories"
end
