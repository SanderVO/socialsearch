class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps
  field :provider, type: String
  field :token, type: String
  field :date_created, type: String
  embedded_in :user, :inverse_of => :authorizations
end
