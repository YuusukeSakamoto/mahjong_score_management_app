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

ActiveRecord::Schema.define(version: 2023_11_16_092625) do

  create_table "chip_results", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "match_group_id", null: false
    t.bigint "player_id", null: false
    t.integer "number", null: false
    t.integer "point", null: false
    t.boolean "is_temporary", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["match_group_id"], name: "index_chip_results_on_match_group_id"
    t.index ["player_id"], name: "index_chip_results_on_player_id"
  end

  create_table "contacts", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.text "content", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "form_bases", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "form_player_collections", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "league_players", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "league_id", null: false
    t.bigint "player_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["league_id"], name: "index_league_players_on_league_id"
    t.index ["player_id"], name: "index_league_players_on_player_id"
  end

  create_table "leagues", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "rule_id", null: false
    t.string "name", null: false
    t.integer "play_type", null: false
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_leagues_on_player_id"
    t.index ["rule_id"], name: "index_leagues_on_rule_id"
  end

  create_table "match_groups", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "rule_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "league_id"
    t.index ["league_id"], name: "index_match_groups_on_league_id"
    t.index ["rule_id"], name: "index_match_groups_on_rule_id"
  end

  create_table "matches", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.bigint "rule_id", null: false
    t.integer "play_type", null: false
    t.date "match_on"
    t.string "memo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "match_group_id"
    t.bigint "league_id"
    t.index ["league_id"], name: "index_matches_on_league_id"
    t.index ["match_group_id"], name: "index_matches_on_match_group_id"
    t.index ["player_id"], name: "index_matches_on_player_id"
    t.index ["rule_id"], name: "index_matches_on_rule_id"
  end

  create_table "players", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id"
    t.string "invite_token"
    t.datetime "invite_create_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["invite_token"], name: "index_players_on_invite_token", unique: true
    t.index ["user_id"], name: "index_players_on_user_id"
  end

  create_table "results", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "player_id", null: false
    t.integer "score", null: false
    t.float "point", null: false
    t.integer "ie", null: false
    t.integer "rank", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["match_id"], name: "index_results_on_match_id"
    t.index ["player_id"], name: "index_results_on_player_id"
  end

  create_table "rules", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "player_id", null: false
    t.string "name", null: false
    t.integer "play_type", null: false
    t.integer "mochi", null: false
    t.integer "kaeshi", null: false
    t.integer "uma_1", null: false
    t.integer "uma_2", null: false
    t.integer "uma_3", null: false
    t.integer "uma_4", null: false
    t.integer "score_decimal_point_calc", null: false
    t.boolean "is_chip", default: false, null: false
    t.integer "chip_rate"
    t.string "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["player_id"], name: "index_rules_on_player_id"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "avatar"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "role", default: 0, null: false
    t.string "player_select_token"
    t.datetime "player_select_token_created_at"
    t.integer "token_issued_user"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["player_select_token"], name: "index_users_on_player_select_token", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chip_results", "match_groups"
  add_foreign_key "chip_results", "players"
  add_foreign_key "contacts", "users"
  add_foreign_key "league_players", "leagues"
  add_foreign_key "league_players", "players"
  add_foreign_key "leagues", "players"
  add_foreign_key "leagues", "rules"
  add_foreign_key "match_groups", "leagues"
  add_foreign_key "match_groups", "rules"
  add_foreign_key "matches", "leagues"
  add_foreign_key "matches", "match_groups"
  add_foreign_key "matches", "players"
  add_foreign_key "matches", "rules"
  add_foreign_key "results", "matches"
  add_foreign_key "results", "players"
  add_foreign_key "rules", "players"
end
