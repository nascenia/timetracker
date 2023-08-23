json.array!(@goals) do |goal|
  json.extract! goal, :id, :title, :description, :point, :percent_completed, :achived_point, :deliverable_link, :comments, :start_date, :end_date, :status
  json.url goal_url(goal, format: :json)
end
