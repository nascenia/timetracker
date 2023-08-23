class ChangeScoreToKpis < ActiveRecord::Migration[7.0]
  def up
    change_column :kpis, :score, :string
  end

  def down
    change_column :kpis, :score, :integer
  end
end
