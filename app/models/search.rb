class Search
  include Mongoid::Document
  include Mongoid::Timestamps
  field :query, type: String
  field :providers, type: Array
  field :results, type: Integer
  belongs_to :user, :inverse_of => :searches
end