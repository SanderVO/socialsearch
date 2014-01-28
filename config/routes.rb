Socialsearch::Application.routes.draw do

  devise_for :users
  
  root :to => 'dashboards#index'

  resources :authorizations

  resources :searches

  resources :users

  resources :dashboards

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"


  # oauth
  get '/auth/:provider/callback' => 'authorizations#create'

  # api
  get '/search/:search'  =>          'api#search'
  post '/search/'         =>          'api#search'

  get '/search/:provider/:search' => 'api#search'
  post '/search/:provider'         => 'api#search'


  match '/auth/:provider/callback' => 'authorizations#create', via: [:get]

  # Admin
  match '/create_admin' => 'users#create_admin', via: [:get, :post]

  # all searches
  get '/all_searches/'  =>  'searches#index_all'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
