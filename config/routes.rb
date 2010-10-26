Nups::Application.routes.draw do
  
  # first created -> highest priority.
  root :to => "home#index"
    
  devise_for :users

  match 'home/menu' => 'home#menu', :as => :menu
  match 'home/top_menu' => 'home#top_menu', :as => :top_menu
  match 'home/main' => 'home#main', :as => :main
  
  match 'newsletters' => 'newsletters#index', :as => :newsletters

  namespace :admin do
    resources :users
    resources :accounts
  end
  
  # resource route with sub-resources:
  resources :accounts, :only => [:index] do
  #scope 'accounts/:account_id/' do
    resources :newsletters do
      member do
        get :start
        get :stop
        get :preview
      end
    end
    
    resources :recipients do
      collection do
        get :import
        post :import
        
        get :multiple_delete
        post :multiple_delete
      end
    end
    
    resources :assets #TODO just create route!
  end

end
