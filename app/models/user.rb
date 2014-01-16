class User
  include Mongoid::Document
  include Mongoid::Timestamps
  field :username, type: String
  field :password, type: String
  field :salt, type: String
  field :email, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :active, type: Integer
  field :activationkey, type: String
  field :city, type: String
  field :country, type: String
  field :street, type: String
  field :postal_code, type: String
  field :gender, type: String
  embeds_many :searches
  embeds_many :authorizations
end
