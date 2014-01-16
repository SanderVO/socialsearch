json.array!(@authorizations) do |authorization|
  json.extract! authorization, :id, :provider, :token, :date_created
  json.url authorization_url(authorization, format: :json)
end
