class CreateWhitelistEmails < ActiveRecord::Migration[7.0]
  def change
    create_table :whitelist_emails do |t|
      t.string :email
      t.boolean :published

      t.timestamps
    end
  end
end
