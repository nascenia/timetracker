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

ActiveRecord::Schema[7.0].define(version: 2023_10_02_091318) do
  create_table "active_admin_comments", charset: "utf8mb4", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", charset: "utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "approval_paths", charset: "utf8mb4", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
  end

  create_table "attendances", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.date "checkin_date"
    t.time "in_time"
    t.time "out_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "total_hours"
    t.integer "parent_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "comments", charset: "utf8mb4", force: :cascade do |t|
    t.text "body"
    t.bigint "leave_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leave_id"], name: "index_comments_on_leave_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "designations", charset: "utf8mb4", force: :cascade do |t|
    t.string "team"
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exclusion_dates", charset: "utf8mb4", force: :cascade do |t|
    t.date "date", null: false
    t.string "excluded_type"
    t.bigint "excluded_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["excluded_type", "excluded_id"], name: "index_exclusion_dates_on_excluded"
  end

  create_table "goal_categories", charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "goals", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.integer "goal_category_id"
    t.integer "reviewer_id"
    t.string "title"
    t.text "description"
    t.decimal "point", precision: 5, scale: 2
    t.decimal "percent_completed", precision: 5, scale: 2
    t.decimal "achived_point", precision: 5, scale: 2
    t.text "deliverable_link"
    t.text "comments"
    t.date "start_date"
    t.date "end_date"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "holiday_schemes", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "leave_year_id"
    t.index ["leave_year_id"], name: "index_holiday_schemes_on_leave_year_id"
  end

  create_table "holidays", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "holiday_scheme_id"
    t.index ["holiday_scheme_id"], name: "index_holidays_on_holiday_scheme_id"
  end

  create_table "kpi_items", charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "kpi_template_id"
    t.index ["kpi_template_id"], name: "index_kpi_items_on_kpi_template_id"
  end

  create_table "kpi_templates", charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "kpis", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.date "start_date"
    t.date "end_date"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "ttf_comment"
    t.text "team_member_comment"
    t.text "data"
    t.index ["user_id"], name: "index_kpis_on_user_id"
  end

  create_table "leave_trackers", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.integer "yearly_casual_leave"
    t.integer "yearly_medical_leave"
    t.integer "carried_forward_vacation"
    t.integer "carried_forward_medical"
    t.integer "accrued_vacation_balance"
    t.integer "accrued_medical_balance"
    t.integer "consumed_medical"
    t.integer "consumed_vacation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "accrued_vacation_this_year", default: 0
    t.integer "accrued_medical_this_year", default: 0
    t.integer "accrued_vacation_total", default: 0
    t.integer "accrued_medical_total", default: 0
    t.datetime "commenced_date"
    t.integer "awarded_leave", default: 0
    t.text "note"
    t.index ["user_id"], name: "index_leave_trackers_on_user_id"
  end

  create_table "leave_years", charset: "utf8mb4", force: :cascade do |t|
    t.string "year"
    t.boolean "present"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leaves", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id"
    t.text "reason"
    t.integer "leave_type"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date"
    t.date "end_date"
    t.integer "half_day", default: 0, null: false
    t.integer "pending_at", null: false
    t.bigint "approval_path_id"
    t.integer "hour"
    t.index ["approval_path_id"], name: "index_leaves_on_approval_path_id"
    t.index ["user_id"], name: "index_leaves_on_user_id"
  end

  create_table "path_chains", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "approval_path_id"
    t.integer "user_id", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["approval_path_id"], name: "index_path_chains_on_approval_path_id"
  end

  create_table "performance_categories", charset: "utf8mb4", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pre_registrations", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "joining_date"
    t.string "datetime"
    t.boolean "nda_signed"
    t.integer "user_id"
    t.string "email_group"
    t.string "contact_number"
    t.string "personal_email"
    t.string "company_email"
    t.string "holiday_scheme_id"
    t.string "weekend_id"
    t.boolean "workstation_ready"
    t.boolean "pack_ready"
    t.integer "step_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "salary_account_details_sent"
    t.boolean "employee_contract_sign"
    t.boolean "id_card_given"
    t.boolean "pic_and_other_relevant_info"
    t.boolean "has_sent_invitation_to_visit_internal_website"
    t.string "designation"
    t.string "nda_doc"
    t.string "hr_email"
    t.integer "ttf_id"
    t.string "employee_id", limit: 16
    t.integer "leave_approval_path_id"
  end

  create_table "projects", charset: "utf8mb4", force: :cascade do |t|
    t.string "project_name"
    t.string "description"
    t.boolean "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects_users", id: false, charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "project_id", null: false
  end

  create_table "promotions", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.string "designation"
    t.string "start_date"
    t.string "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_promotions_on_user_id"
  end

  create_table "timesheets", charset: "utf8mb4", force: :cascade do |t|
    t.date "date"
    t.text "description"
    t.bigint "project_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "task"
    t.string "ticket_number"
    t.text "ticket_link"
    t.integer "hours"
    t.integer "minutes"
    t.index ["project_id"], name: "index_timesheets_on_project_id"
    t.index ["user_id"], name: "index_timesheets_on_user_id"
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "is_active", default: true
    t.integer "role"
    t.integer "ttf_id"
    t.integer "sttf_id"
    t.bigint "approval_path_id"
    t.bigint "weekend_id"
    t.bigint "holiday_scheme_id"
    t.string "personal_email"
    t.text "present_address"
    t.string "mobile_number"
    t.string "alternate_contact"
    t.text "permanent_address"
    t.date "date_of_birth"
    t.string "last_degree"
    t.string "last_university"
    t.string "passing_year"
    t.string "emergency_contact_person_name"
    t.string "emergency_contact_person_relation"
    t.string "emergency_contact_person_number"
    t.string "blood_group"
    t.date "joining_date"
    t.date "resignation_date"
    t.boolean "is_published", default: false
    t.string "avatar"
    t.integer "registration_status", default: 0
    t.string "resume"
    t.string "national_id"
    t.string "passport"
    t.string "bank_account_no"
    t.text "profile_update_json"
    t.string "employee_id", limit: 16
    t.integer "kpi_template_id"
    t.index ["approval_path_id"], name: "index_users_on_approval_path_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["holiday_scheme_id"], name: "index_users_on_holiday_scheme_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["weekend_id"], name: "index_users_on_weekend_id"
  end

  create_table "versions", charset: "utf8mb4", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "weekends", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "off_days"
  end

  create_table "whitelist_emails", charset: "utf8mb4", force: :cascade do |t|
    t.string "email"
    t.boolean "published"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "users", "approval_paths"
end
