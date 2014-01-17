class Search
  include Mongoid::Document
  include Mongoid::Timestamps
  field :query, type: String
  embedded_in :user, :inverse_of => :searches
end
