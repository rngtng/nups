Nups::Application.routes.draw do
  
  # first created -> highest priority.
  root :to => "home#index"
    
  devise_for :users

  match 'home/menu' => 'home#menu', :as => :menu
  match 'home/top_menu' => 'home#top_menu', :as => :top_menu
  match 'home/main' => 'home#main', :as => :main
  
  match 'newsletters' => 'newsletters#index', :as => :newsletters

  resources :users
    
  # resource route with sub-resources:
  resources :accounts do
    resources :newsletters do
      member do
        get :start
        get :stop
        get :preview
      end
    end
    resources :recipients
  end

end
