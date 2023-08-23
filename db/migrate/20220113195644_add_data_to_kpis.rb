class AddDataToKpis < ActiveRecord::Migration[7.0]
  def change
    add_column  :kpis, :data, :text
  end
end
