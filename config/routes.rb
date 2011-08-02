Nups::Application.routes.draw do
  # first created -> highest priority.
  root :to => "frame#index"

  devise_for :users

  match 'newsletters' => 'newsletters#index', :as => :newsletters

  match 'unsubscribe/:account_id/:id' => 'public/recipients#show',    :via => 'get',    :as => :unsubscribe
  match 'unsubscribe/:account_id/:id' => 'public/recipients#destroy', :via => 'delete'

  namespace :admin do
    resources :users
    resources :accounts
  end

  namespace :public do
    resources :recipients, :only => [:index, :show, :destroy]
  end

  # resource route with sub-resources:
  resources :accounts, :only => [:index] do
    resources :newsletters do
      member do
        get :start
        get :stop
      end
    end

    resources :recipients do
      collection do
        get :delete
        delete :multiple_destroy
      end
    end

    resources :assets #TODO just create route!
  end

end
