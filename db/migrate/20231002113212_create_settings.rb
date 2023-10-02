class CreateSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :settings do |t|
	    t.string :app_name, null: false
      t.string :organization_name, null: false
      t.string :organization_summary, null: false
      t.string :organization_logo, null: true
      t.string :organization_web_url, null: true
      t.string :copyright, null: true
      t.string :meta_author, null: true
      t.string :meta_title, null: true
      t.string :meta_description, null: true
      t.string :meta_keywords, null: true
      t.string :meta_viewport, null: true

      t.timestamps
    end
  end
end
