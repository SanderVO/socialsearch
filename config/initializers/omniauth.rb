Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, 'jrQQLPvLRzJ9lLf6pd8r3Q', 's5ylJSbIyX8t51bZIZY14hTwVFoG9k3SIUPbe6cNJo'
  provider :facebook, '209517239225925', '56cb478b9233be009097319e5c22a5d4'
  provider :linked_in, 'XOL81gTsUjyyHoIl', '6a38a300-1e05-40c9-a2b0-5ab4bc6e1482'
end