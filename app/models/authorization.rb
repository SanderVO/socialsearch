class Authorization
  include Mongoid::Document
  include Mongoid::Timestamps
  field :uid, type: String
  field :provider, type: String
  field :token, type: String
  belongs_to :user
end
