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

ActiveRecord::Schema[7.0].define(version: 2023_10_02_123108) do
  create_table "active_admin_comments", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "namespace"
    t.text "body", size: :medium
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "admin_users", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "approval_paths", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name", null: false
  end

  create_table "attendances", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.date "checkin_date"
    t.time "in_time"
    t.time "out_time"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.float "total_hours"
    t.integer "parent_id"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "comments", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.text "body", size: :medium
    t.integer "leave_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["leave_id"], name: "index_comments_on_leave_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "designations", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "team"
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "exclusion_dates", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.date "date", null: false
    t.integer "excluded_id"
    t.string "excluded_type"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["excluded_id", "excluded_type"], name: "index_exclusion_dates_on_excluded_id_and_excluded_type"
  end

  create_table "goal_categories", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "goals", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "holiday_schemes", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.boolean "active", default: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "leave_year_id"
    t.index ["leave_year_id"], name: "index_holiday_schemes_on_leave_year_id"
  end

  create_table "holidays", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.date "date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "holiday_scheme_id"
    t.index ["holiday_scheme_id"], name: "index_holidays_on_holiday_scheme_id"
  end

  create_table "honor_board_categories", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "category", default: "", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "honor_board_contents", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.text "reason", size: :medium
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "honor_board_category_id"
    t.string "photo"
    t.index ["honor_board_category_id"], name: "index_honor_board_contents_on_honor_board_category_id"
  end

  create_table "kpi_items", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "kpi_template_id"
    t.index ["kpi_template_id"], name: "index_kpi_items_on_kpi_template_id"
  end

  create_table "kpi_templates", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "kpis", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.date "start_date"
    t.date "end_date"
    t.integer "status"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "ttf_comment"
    t.text "team_member_comment"
    t.text "data"
    t.index ["user_id"], name: "index_kpis_on_user_id"
  end

  create_table "leave_trackers", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.integer "yearly_casual_leave"
    t.integer "yearly_medical_leave"
    t.integer "carried_forward_vacation"
    t.integer "carried_forward_medical"
    t.integer "accrued_vacation_balance"
    t.integer "accrued_medical_balance"
    t.integer "consumed_medical"
    t.integer "consumed_vacation"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "accrued_vacation_this_year", default: 0
    t.integer "accrued_medical_this_year", default: 0
    t.integer "accrued_vacation_total", default: 0
    t.integer "accrued_medical_total", default: 0
    t.datetime "commenced_date", precision: nil
    t.integer "awarded_leave", default: 0
    t.text "note", size: :medium
    t.index ["user_id"], name: "index_leave_trackers_on_user_id"
  end

  create_table "leave_years", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "year"
    t.boolean "present"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "leaves", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.text "reason", size: :medium
    t.integer "leave_type"
    t.integer "status"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.date "start_date"
    t.date "end_date"
    t.integer "half_day", default: 0, null: false
    t.integer "pending_at", null: false
    t.integer "approval_path_id"
    t.integer "hour"
    t.index ["approval_path_id"], name: "index_leaves_on_approval_path_id"
    t.index ["user_id"], name: "index_leaves_on_user_id"
  end

  create_table "path_chains", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "approval_path_id"
    t.integer "user_id", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["approval_path_id"], name: "index_path_chains_on_approval_path_id"
  end

  create_table "performance_categories", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.boolean "published"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "pre_registrations", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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

  create_table "projects", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "project_name"
    t.string "description"
    t.boolean "is_active"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "projects_users", id: false, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
  end

  create_table "promotions", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.integer "user_id"
    t.string "designation"
    t.string "start_date"
    t.string "end_date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["user_id"], name: "index_promotions_on_user_id"
  end

  create_table "salaats", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "waqt"
    t.time "time"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "settings", charset: "latin1", force: :cascade do |t|
    t.string "app_name", null: false
    t.string "organization_name", null: false
    t.string "organization_summary", null: false
    t.string "organization_logo"
    t.string "organization_web_url"
    t.string "copyright"
    t.string "meta_author"
    t.string "meta_title"
    t.string "meta_description"
    t.string "meta_keywords"
    t.string "meta_viewport"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fav_icon"
  end

  create_table "timesheets", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.date "date"
    t.text "description", size: :medium
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.text "task", size: :medium
    t.string "ticket_number"
    t.text "ticket_link", size: :medium
    t.integer "hours"
    t.integer "minutes"
    t.index ["project_id"], name: "index_timesheets_on_project_id"
    t.index ["user_id"], name: "index_timesheets_on_user_id"
  end

  create_table "users", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "name"
    t.boolean "is_active", default: true
    t.integer "role"
    t.integer "ttf_id"
    t.integer "sttf_id"
    t.integer "approval_path_id"
    t.integer "weekend_id"
    t.integer "holiday_scheme_id"
    t.string "personal_email"
    t.text "present_address", size: :medium
    t.string "mobile_number"
    t.string "alternate_contact"
    t.text "permanent_address", size: :medium
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
    t.string "resume_filename"
    t.string "national_id_filename"
    t.string "passport_filename"
    t.string "avatar_filename"
    t.text "profile_update_json"
    t.string "employee_id", limit: 16
    t.integer "kpi_template_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["holiday_scheme_id"], name: "index_users_on_holiday_scheme_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["weekend_id"], name: "index_users_on_weekend_id"
  end

  create_table "versions", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "item_type", limit: 191, null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", size: :long
    t.datetime "created_at", precision: nil
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "weekends", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "off_days"
  end

  create_table "whitelist_emails", id: :integer, charset: "utf8", collation: "utf8_unicode_ci", force: :cascade do |t|
    t.string "email"
    t.boolean "published"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

end
