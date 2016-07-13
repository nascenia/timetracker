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

ActiveRecord::Schema.define(version: 20160712121647) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "attendances", force: true do |t|
    t.integer  "user_id"
    t.date     "datetoday"
    t.time     "in_time"
    t.time     "out_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "total_hours"
    t.boolean  "first_entry", default: false
  end

  add_index "attendances", ["user_id"], name: "index_attendances_on_user_id", using: :btree

  create_table "leave_trackers", force: true do |t|
    t.integer  "user_id"
    t.integer  "yearly_casual_leave"
    t.integer  "yearly_medical_leave"
    t.integer  "carried_forward_vacation"
    t.integer  "carried_forward_medical"
    t.integer  "accrued_vacation_balance"
    t.integer  "accrued_medical_balance"
    t.integer  "consumed_medical"
    t.integer  "consumed_vacation"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "accrued_vacation_this_year", default: 0
    t.integer  "accrued_medical_this_year",  default: 0
    t.integer  "accrued_vacation_total",     default: 0
    t.integer  "accrued_medical_total",      default: 0
    t.datetime "commenced_date"
  end

  add_index "leave_trackers", ["user_id"], name: "index_leave_trackers_on_user_id", using: :btree

  create_table "leaves", force: true do |t|
    t.integer  "user_id"
    t.text     "reason"
    t.integer  "leave_type"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "half_day"
  end

  add_index "leaves", ["user_id"], name: "index_leaves_on_user_id", using: :btree

  create_table "salaats", force: true do |t|
    t.string   "waqt"
    t.time     "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "is_active",              default: true
    t.integer  "role"
    t.integer  "ttf_id"
    t.integer  "sttf_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
