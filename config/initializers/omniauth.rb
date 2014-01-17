Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '282931165187802', 'a88e3434c73604201b91db1d50dc0fcd', :scope => 'email'
end