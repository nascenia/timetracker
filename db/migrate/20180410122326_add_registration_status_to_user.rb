class AddRegistrationStatusToUser < ActiveRecord::Migration
  def change
    add_column :users , :registration_status , :integer , default: 0
  end
end
