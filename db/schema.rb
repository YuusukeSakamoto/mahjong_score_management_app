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

ActiveRecord::Schema.define(version: 2023_05_13_015704) do

  create_table "form_bases", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "form_player_collections", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "form_result_collections", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "group_users", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_group_users_on_group_id"
    t.index ["user_id"], name: "index_group_users_on_user_id"
  end

  create_table "groups", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "member_count", null: false
    t.index ["user_id"], name: "index_groups_on_user_id"
  end

  create_table "members", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.integer "represent_user_flag", default: 0, null: false
    t.integer "general_user_flag", default: 0, null: false
    t.bigint "group_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["group_id"], name: "index_members_on_group_id"
  end

  create_table "players", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "results", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "rule_id", null: false
    t.date "match_time", null: false
    t.integer "score", null: false
    t.integer "point", null: false
    t.integer "ie", null: false
    t.integer "recorded_player_id", null: false
    t.string "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_results_on_player_id"
    t.index ["rule_id"], name: "index_results_on_rule_id"
  end

  create_table "rules", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.string "name", null: false
    t.integer "mochi", null: false
    t.integer "kaeshi", null: false
    t.integer "uma_1", null: false
    t.integer "uma_2", null: false
    t.integer "uma_3", null: false
    t.integer "uma_4", null: false
    t.integer "score_decimal_point_calc", null: false
    t.integer "chip_existence_flag", null: false
    t.integer "chip_rate"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_rules_on_player_id"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name", null: false
    t.integer "admin_flag"
    t.string "avatar"
    t.integer "member_id", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "group_users", "groups"
  add_foreign_key "group_users", "users"
  add_foreign_key "groups", "users"
  add_foreign_key "members", "groups"
  add_foreign_key "results", "players"
  add_foreign_key "results", "rules"
  add_foreign_key "rules", "players"
end
