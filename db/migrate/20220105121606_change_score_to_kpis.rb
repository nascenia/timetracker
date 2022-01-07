class ChangeScoreToKpis < ActiveRecord::Migration
  def up
    change_column :kpis, :score, :string
  end

  def down
    change_column :kpis, :score, :integer
  end
end
