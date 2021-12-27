json.array!(@kpi_items) do |kpi_item|
  json.extract! kpi_item, :id, :title, :description, :score, :start_date, :end_date, :status
  json.url kpi_item_url(kpi_item, format: :json)
end
