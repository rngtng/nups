
Nups::Application.routes.draw do
  mount Resque::Server.new => "/resque"

  # first created -> highest priority.
  root :to => "frame#index"

  devise_for :users

  match 'newsletters' => 'newsletters#index', :as => :newsletters
  match 'newsletters/stats' => 'newsletters#stats', :as => :newsletter_stats

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

      resources :send_outs
    end

    resources :assets #TODO just create route!
  end

  match 'subscribe/:account_permalink' => 'public/recipients#new',    :via => 'get',    :as => :subscribe
  match 'subscribe/:account_permalink' => 'public/recipients#create', :via => 'post'
  match 'unsubscribe/:account_id/:id' => 'public/recipients#show',    :via => 'get',    :as => :unsubscribe
  match 'unsubscribe/:account_id/:id' => 'public/recipients#destroy', :via => 'delete'

  match ':recipient_id/:send_out_id' => 'public/newsletters#show', :via => 'get', :as => :public_newsletter
end
