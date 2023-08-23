class RemoveTitleDescriptionScoreFromKpis < ActiveRecord::Migration[7.0]
  def change
    remove_column :kpis, :title,        :string
    remove_column :kpis, :description,  :text
    remove_column :kpis, :score,        :string
  end
end
