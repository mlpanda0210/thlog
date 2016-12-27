Rails.application.routes.draw do
devise_for :admin,
controllers: {
  sessions: 'admin/sessions',
  registrations: 'admin/registrations'}

devise_for :users, controllers: {
  omniauth_callbacks: "users/omniauth_callbacks" }

get 'gcales' => 'gcales#index'
get 'gcales/new' => 'gcales#new'
get 'gcales/update_schedule' => 'gcales#update_schedule'

get 'gcales/admin_comparison_project' => 'gcales#admin_comparison_project'
get 'gcales/admin_comparison_working_time' => 'gcales#admin_comparison_working_time'

get 'admin/admin_comparison_project' => 'admin#admin_comparison_project'
get 'admin/admin_comparison_working_time' => 'admin#admin_comparison_working_time'

delete 'gcales' => 'gcales#destroy_tag'
get 'gcales/new_tag' => 'gcales#new_tag'
get 'gcales/create_tag' => 'gcales#create_tag'
post 'gcales/create_tag' => 'gcales#create_tag'
get 'gcales/edit_tag' => 'gcales#edit_tag'
get 'gcales/update_tag' => 'gcales#update_tag'
get 'gcales/index_month_project' => 'gcales#index_month_project'
get 'gcales/show_month_project' => 'gcales#show_month_project'
get 'gcales/day' => 'gcales#day'
root'gcales#index'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
