json.array!(@kpis) do |kpi|
  json.extract! kpi, :id, :title, :description, :score, :start_date, :end_date, :status
  json.url kpi_url(kpi, format: :json)
end
