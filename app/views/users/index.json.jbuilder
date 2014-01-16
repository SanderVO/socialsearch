json.array!(@users) do |user|
  json.extract! user, :id, :username, :password, :salt, :email, :first_name, :last_name, :date_created, :date_updated, :active, :activationkey, :city, :country, :street, :postal_code, :gender
  json.url user_url(user, format: :json)
end
