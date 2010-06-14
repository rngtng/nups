Nups::Application.routes.draw do |map|
  
  # first created -> highest priority.
  root :to => "home#index"
    
  devise_for :users

  match 'home/menu' => 'home#menu', :as => :menu
  match 'home/main' => 'home#main', :as => :main
  
  match 'newsletters' => 'newsletters#index', :as => :newsletters

  resources :users
    
  # resource route with sub-resources:
  resources :accounts do
    resources :newsletters do
      
    end
    resources :recipients
  end

end
