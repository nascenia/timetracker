class AddBankAccountNoToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :bank_account_no, :string
  end
end
