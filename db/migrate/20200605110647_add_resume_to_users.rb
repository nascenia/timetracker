class AddResumeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :resume, :string
  end
end
