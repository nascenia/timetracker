class AddBankAccountNoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bank_account_no, :string
  end
end
