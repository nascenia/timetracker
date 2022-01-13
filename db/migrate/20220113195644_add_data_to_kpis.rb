class AddDataToKpis < ActiveRecord::Migration
  def change
    add_column  :kpis, :data, :text
  end
end
