json.array!(@leaves) do |leafe|
  json.extract! leafe, :id, :user_id, :reason, :leave_type, :status
  json.url leafe_url(leafe, format: :json)
end
