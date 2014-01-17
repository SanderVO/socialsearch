class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uid, type: String
  field :provider, type: String
  field :token, type: String
  embedded_in :user, :inverse_of => :authorizations
end
