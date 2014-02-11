Grouping::Application.routes.draw do
	
	#---groups---
	resources :groups do
		collection { post :import_excel }
		member do
			post :rate
		end
	end
	
	root :to => "groups#index"
	get 'import', to: 'groups#import', as: 'import'
	
	match 'setGroup', to: 'groups#set_group', as: 'setGroup'
	match 'createGroup', to: 'groups#create_group', as: 'createGroup'
	
	match 'searchGroup', to: 'groups#search_group', as: 'searchGroup'
	match 'viewClass', to: 'groups#view_class', as: 'viewClass'
	
	#---users---
  resources :users
  resources :sessions
	
	get 'signup', to: 'users#new', as: 'signup'
	get 'login', to: 'sessions#new', as: 'login'
	get 'logout', to: 'sessions#destroy', as: 'logout'
	
	get 'newPassword', to: 'sessions#new_password', as: 'newPassword'
	post 'changePassword', to: 'sessions#change_password', as: 'changePassword'
	
	match 'viewScore', to: 'users#view_score', as: 'viewScore'
	
	#---school class & course---
	resources :courses
	resources :school_classes
	
	match 'macourse', to: 'groups#manual_add_course', as: 'macourse'
	match 'ccourse', to: 'groups#create_course', as: 'ccourse'
	
	match 'mastudent', to: 'groups#manual_add_student', as: 'mastudent'
	match 'cstudent', to: 'groups#create_student', as: 'cstudent'
	
	match 'chooseCourse', to: 'groups#choose_course', as: 'chooseCourse'
	match 'setCourse', to: 'groups#set_course', as: 'setCourse'
	match 'setTutor', to: 'groups#set_tutor', as: 'setTutor'
	match 'removeTutor', to: 'groups#remove_tutor', as: 'removeTutor'
	match 'course/:c_id/chooseStudent', to: 'groups#choose_student', as: 'chooseStudent'
	match 'addStuToCourse', to: 'groups#add_student_to_course', as: 'addStuToCourse'
	
	match 'viewCourse', to: 'groups#view_course', as: 'viewCourse'
	
	#---Task---
	resources :tasks do
		collection do 
			post :group_excel
			post :score_excel
		end
	end
	match '/course/:c_id/new', to: 'tasks#new', as: 'new_task'
	match '/tasks/create', to: 'tasks#create', as: 'create_task'
	match '/course/:c_id/index', to: 'tasks#index', as: 'index_task'
	match '/tasks/:id', to: 'tasks#update', as: 'update_task'
	delete '/tasks/:id', to: 'tasks#destroy', as: 'delete_task'
	match '/tasks/:id/importGroup', to: 'tasks#import_group', as: 'importGroup'
	match '/tasks/:id/importScore', to: 'tasks#import_score', as: 'importScore'
	match '/tasks/:id/viewGroup', to: 'tasks#view_group', as: 'viewGroup'
	match 'removeGroup', to: 'tasks#remove_group', as: 'removeGroup'
	match '/tasks/:id/uploadFile', to: 'tasks#upload_file', as: 'uploadFile'
	match '/tasks/:id/editFile', to: 'tasks#edit_file', as: 'editFile'

	#--Member_Rate--
	resources :member_rates do
		member do
			post :rate
		end
	end
	
	# get "welcome/say_hello" => "welcome#say"
	# get "welcome" => "welcome#index"
	
	
	
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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
