class RemoveTitleDescriptionScoreFromKpis < ActiveRecord::Migration
  def change
    remove_column :kpis, :title,        :string
    remove_column :kpis, :description,  :text
    remove_column :kpis, :score,        :string
  end
end
