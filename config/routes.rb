Clearing::Application.routes.draw do
  
  root :to => 'main#home'
  match 'about' => 'main#about', :as => :about
  match 'contact_us' => 'main#contact_us', :as => :contact_us
  match 'donate' => 'donations#show'
  match 'confirm_donation' => 'donations#reserve_and_donate'
  match 'process_non_concert_donation' => 'donations#process_donation'
  
  match 'static_jpg_image/:image_name' => 'main#static_image'
  
  namespace :admin do
    resources :concerts
    match 'reservations/report/:id' => 'reports#reservations', :as => :reservations_report
    match 'will_call/report/:id' => 'reports#will_call_list', :as => :will_call_list
    match 'memorials/report/:id' => 'reports#memorials', :as => :memorials_report
    match 'enter_walkups/:id' => 'miscellaneous#enter_walkups', :as => :enter_walkups
    match 'add_walkup' => 'miscellaneous#add_walkup'
    match 'create_patron_csv' => 'miscellaneous#create_patron_csv'
    match 'sustaining_donations' => 'reports#sustaining_donations'
  end
  
  match 'concerts/intro' => 'concerts#intro', :as => :concerts_intro
  match 'concerts/:ident_string' => 'concerts#show', :as => :concert
  match 'concerts/print/:ident_string' => 'concerts#print'
  
  match 'show_ticket_form/:ident_string' => 'tickets#show', :as => :show_ticket_form
  match 'reserve_tickets' => 'tickets#reserve_and_donate', :as => :reserve_tickets
  match 'ticket_success'  => 'tickets#success', :as => :ticket_success
  match 'process_donation'  => 'tickets#process_donation', :as => :process_donation
  match 'print_tickets/:unique_token'   => 'tickets#print',   :as => :print_tickets
  
  match 'admin' => 'admin#menu', :as => :admin
  match 'admin/:action', :controller => 'admin'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
