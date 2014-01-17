Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '282931165187802', 'a88e3434c73604201b91db1d50dc0fcd', :scope => 'email'
  provider :twitter, 'jrQQLPvLRzJ9lLf6pd8r3Q', 's5ylJSbIyX8t51bZIZY14hTwVFoG9k3SIUPbe6cNJo'
  provider :linked_in, 'XOL81gTsUjyyHoIl', '6a38a300-1e05-40c9-a2b0-5ab4bc6e1482'
end