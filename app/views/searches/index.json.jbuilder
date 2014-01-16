json.array!(@searches) do |search|
  json.extract! search, :id, :query, :date
  json.url search_url(search, format: :json)
end
