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

ActiveRecord::Schema.define(version: 20211119103746) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body",          limit: 16777215
    t.string   "resource_id",                    null: false
    t.string   "resource_type",                  null: false
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

  create_table "approval_paths", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       null: false
  end

  create_table "attendances", force: true do |t|
    t.integer  "user_id"
    t.date     "checkin_date"
    t.time     "in_time"
    t.time     "out_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "total_hours"
    t.integer  "parent_id"
  end

  add_index "attendances", ["user_id"], name: "index_attendances_on_user_id", using: :btree

  create_table "comments", force: true do |t|
    t.text     "body",       limit: 16777215
    t.integer  "leave_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["leave_id"], name: "index_comments_on_leave_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "designations", force: true do |t|
    t.string   "team"
    t.string   "title"
    t.text     "description"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "exclusion_dates", force: true do |t|
    t.date     "date",          null: false
    t.integer  "excluded_id"
    t.string   "excluded_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "exclusion_dates", ["excluded_id", "excluded_type"], name: "index_exclusion_dates_on_excluded_id_and_excluded_type", using: :btree

  create_table "goal_categories", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.boolean  "published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "holiday_schemes", force: true do |t|
    t.string   "name"
    t.boolean  "active",        default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "leave_year_id"
  end

  add_index "holiday_schemes", ["leave_year_id"], name: "index_holiday_schemes_on_leave_year_id", using: :btree

  create_table "holidays", force: true do |t|
    t.string   "name"
    t.date     "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "holiday_scheme_id"
  end

  add_index "holidays", ["holiday_scheme_id"], name: "index_holidays_on_holiday_scheme_id", using: :btree

  create_table "honor_board_categories", force: true do |t|
    t.string   "category",   default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "honor_board_contents", force: true do |t|
    t.string   "name"
    t.text     "reason",                  limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "honor_board_category_id"
    t.string   "photo"
  end

  add_index "honor_board_contents", ["honor_board_category_id"], name: "index_honor_board_contents_on_honor_board_category_id", using: :btree

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
    t.integer  "accrued_vacation_this_year",                  default: 0
    t.integer  "accrued_medical_this_year",                   default: 0
    t.integer  "accrued_vacation_total",                      default: 0
    t.integer  "accrued_medical_total",                       default: 0
    t.datetime "commenced_date"
    t.integer  "awarded_leave",                               default: 0
    t.text     "note",                       limit: 16777215
  end

  add_index "leave_trackers", ["user_id"], name: "index_leave_trackers_on_user_id", using: :btree

  create_table "leave_years", force: true do |t|
    t.string   "year"
    t.boolean  "present"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "leaves", force: true do |t|
    t.integer  "user_id"
    t.text     "reason",           limit: 16777215
    t.integer  "leave_type"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "half_day",                          default: 0, null: false
    t.integer  "pending_at",                                    null: false
    t.integer  "approval_path_id"
    t.integer  "hour"
  end

  add_index "leaves", ["approval_path_id"], name: "index_leaves_on_approval_path_id", using: :btree
  add_index "leaves", ["user_id"], name: "index_leaves_on_user_id", using: :btree

  create_table "path_chains", force: true do |t|
    t.integer  "approval_path_id"
    t.integer  "user_id",                      null: false
    t.integer  "priority",         default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "path_chains", ["approval_path_id"], name: "index_path_chains_on_approval_path_id", using: :btree

  create_table "pre_registrations", force: true do |t|
    t.string   "name"
    t.string   "joiningDate"
    t.string   "datetime"
    t.boolean  "NdaSigned"
    t.integer  "user_id"
    t.string   "emailGroup"
    t.string   "contactNumber"
    t.string   "personalEmail"
    t.string   "companyEmail"
    t.string   "holiday_scheme_id"
    t.string   "weekend_id"
    t.boolean  "workstationReady"
    t.boolean  "packReady"
    t.integer  "step_no"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "salary_account_details_sent"
    t.boolean  "employee_contract_sign"
    t.boolean  "id_card_given"
    t.boolean  "pic_and_other_relevant_info"
    t.boolean  "has_sent_invitation_to_visit_internal_website"
    t.string   "designation"
    t.string   "ndaDoc"
    t.string   "HR_email"
    t.integer  "ttf_id"
    t.string   "employee_id",                                   limit: 16
    t.integer  "leave_approval_path_id"
  end

  create_table "projects", force: true do |t|
    t.string   "project_name"
    t.string   "description"
    t.boolean  "is_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "projects_users", id: false, force: true do |t|
    t.integer "user_id",    null: false
    t.integer "project_id", null: false
  end

  create_table "promotions", force: true do |t|
    t.integer  "user_id"
    t.string   "designation"
    t.string   "start_date"
    t.string   "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "promotions", ["user_id"], name: "index_promotions_on_user_id", using: :btree

  create_table "salaats", force: true do |t|
    t.string   "waqt"
    t.time     "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "timesheets", force: true do |t|
    t.date     "date"
    t.text     "description",   limit: 16777215
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "task",          limit: 16777215
    t.string   "ticket_number"
    t.text     "ticket_link",   limit: 16777215
    t.integer  "hours"
    t.integer  "minutes"
  end

  add_index "timesheets", ["project_id"], name: "index_timesheets_on_project_id", using: :btree
  add_index "timesheets", ["user_id"], name: "index_timesheets_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                                              default: "",    null: false
    t.string   "encrypted_password",                                 default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "is_active",                                          default: true
    t.integer  "role"
    t.integer  "ttf_id"
    t.integer  "sttf_id"
    t.integer  "approval_path_id"
    t.integer  "weekend_id"
    t.integer  "holiday_scheme_id"
    t.string   "personal_email"
    t.text     "present_address",                   limit: 16777215
    t.string   "mobile_number"
    t.string   "alternate_contact"
    t.text     "permanent_address",                 limit: 16777215
    t.date     "date_of_birth"
    t.string   "last_degree"
    t.string   "last_university"
    t.string   "passing_year"
    t.string   "emergency_contact_person_name"
    t.string   "emergency_contact_person_relation"
    t.string   "emergency_contact_person_number"
    t.string   "blood_group"
    t.date     "joining_date"
    t.date     "resignation_date"
    t.boolean  "is_published",                                       default: false
    t.string   "avatar"
    t.integer  "registration_status",                                default: 0
    t.string   "resume"
    t.string   "national_id"
    t.string   "passport"
    t.string   "bank_account_no"
    t.string   "resume_filename"
    t.string   "national_id_filename"
    t.string   "passport_filename"
    t.string   "avatar_filename"
    t.text     "profile_update_json"
    t.string   "employee_id",                       limit: 16
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["holiday_scheme_id"], name: "index_users_on_holiday_scheme_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["weekend_id"], name: "index_users_on_weekend_id", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",      limit: 191,        null: false
    t.integer  "item_id",                           null: false
    t.string   "event",                             null: false
    t.string   "whodunnit"
    t.text     "object",         limit: 2147483647
    t.datetime "created_at"
    t.text     "object_changes"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "weekends", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "off_days"
  end

end
