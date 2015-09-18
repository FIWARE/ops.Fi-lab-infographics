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

ActiveRecord::Schema.define(version: 20150813193654) do

  create_table "fi_lab_app_organizations", force: true do |t|
    t.string   "name"
    t.integer  "actorId"
    t.integer  "rid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fi_lab_app_roles", force: true do |t|
    t.string   "name"
    t.string   "rid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fi_lab_app_users", force: true do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.text     "token"
    t.text     "refresh_token"
    t.string   "name"
    t.string   "nickname"
    t.integer  "node_id"
    t.string   "actorid"
  end

  create_table "fi_lab_infographics_institutions", force: true do |t|
    t.string "name"
    t.string "logo"
    t.string "link"
    t.text   "description"
  end

  create_table "fi_lab_infographics_messages", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "node_id"
    t.string   "message"
    t.datetime "created_at"
  end

  create_table "fi_lab_infographics_node_categories", force: true do |t|
    t.string "name"
    t.string "logo"
    t.text   "description"
  end

  create_table "fi_lab_infographics_nodes", force: true do |t|
    t.string  "rid"
    t.string  "name"
    t.string  "jira_project_url"
    t.string  "jira_project_id"
    t.integer "category_id"
  end

  create_table "fi_lab_infographics_nodes_institutions", id: false, force: true do |t|
    t.integer "node_id",        null: false
    t.integer "institution_id", null: false
  end

  create_table "fi_lap_app_roles_organizations", id: false, force: true do |t|
    t.integer "role_id",         null: false
    t.integer "organization_id", null: false
  end

  create_table "fi_lap_app_users_organizations", id: false, force: true do |t|
    t.integer "user_id",         null: false
    t.integer "organization_id", null: false
  end

  create_table "fi_lap_app_users_roles", id: false, force: true do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
  end

end
