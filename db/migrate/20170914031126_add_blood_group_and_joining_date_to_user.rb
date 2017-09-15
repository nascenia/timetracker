class AddBloodGroupAndJoiningDateToUser < ActiveRecord::Migration
  def change
    add_column :users, :personal_email, :string
    add_column :users, :present_address, :text
    add_column :users, :mobile_number, :string
    add_column :users, :alternate_contact, :string
    add_column :users, :permanent_address, :text
    add_column :users, :date_of_birth, :date
    add_column :users, :last_degree, :string
    add_column :users, :last_university, :string
    add_column :users, :passing_year, :string
    add_column :users, :emergency_contact_person_name, :string
    add_column :users, :emergency_contact_person_relation, :string
    add_column :users, :emergency_contact_person_number, :string
    add_column :users, :blood_group, :string
    add_column :users, :joining_date, :date
  end
end
