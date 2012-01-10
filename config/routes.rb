
Nups::Application.routes.draw do
  mount Resque::Server.new => "/resque"

  # first created -> highest priority.
  root :to => "frame#index"

  devise_for :users

  match 'newsletters' => 'newsletters#index', :as => :all_newsletters
  match 'newsletters/stats' => 'newsletters#stats', :as => :all_newsletter_stats

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

    resources :assets, :only => :create
    resources :charts, :only => :index
  end

  match 'subscribe/:account_permalink'        => 'public/recipients#create',           :via => 'post',  :as => :subscribe
  match 'confirm/:recipient_confirm_code'     => 'public/recipients#confirm',          :via => 'get',   :as => :confirm #put
  match 'unsubscribe/:recipient_confirm_code' => 'public/recipients#destroy_confirm',  :via => 'get',   :as => :unsubscribe
  match 'unsubscribe/:recipient_confirm_code' => 'public/recipients#destroy',          :via => 'delete'
  match 'remove/:account_permalink'           => 'public/recipients#destroy_by_email', :via => 'delete'

  match ':recipient_id/:send_out_id(/:image)' => 'public/newsletters#show',            :via => 'get',   :as => :newsletter
end
#== Route Map
# Generated on 10 Jan 2012 19:05
#
#                                root        /                                                                           frame#index
#                    new_user_session GET    /users/sign_in(.:format)                                                    devise/sessions#new
#                        user_session POST   /users/sign_in(.:format)                                                    devise/sessions#create
#                destroy_user_session GET    /users/sign_out(.:format)                                                   devise/sessions#destroy
#                       user_password POST   /users/password(.:format)                                                   devise/passwords#create
#                   new_user_password GET    /users/password/new(.:format)                                               devise/passwords#new
#                  edit_user_password GET    /users/password/edit(.:format)                                              devise/passwords#edit
#                                     PUT    /users/password(.:format)                                                   devise/passwords#update
#            cancel_user_registration GET    /users/cancel(.:format)                                                     devise/registrations#cancel
#                   user_registration POST   /users(.:format)                                                            devise/registrations#create
#               new_user_registration GET    /users/sign_up(.:format)                                                    devise/registrations#new
#              edit_user_registration GET    /users/edit(.:format)                                                       devise/registrations#edit
#                                     PUT    /users(.:format)                                                            devise/registrations#update
#                                     DELETE /users(.:format)                                                            devise/registrations#destroy
#                     all_newsletters        /newsletters(.:format)                                                      newsletters#index
#                all_newsletter_stats        /newsletters/stats(.:format)                                                newsletters#stats
#                         admin_users GET    /admin/users(.:format)                                                      admin/users#index
#                                     POST   /admin/users(.:format)                                                      admin/users#create
#                      new_admin_user GET    /admin/users/new(.:format)                                                  admin/users#new
#                     edit_admin_user GET    /admin/users/:id/edit(.:format)                                             admin/users#edit
#                          admin_user GET    /admin/users/:id(.:format)                                                  admin/users#show
#                                     PUT    /admin/users/:id(.:format)                                                  admin/users#update
#                                     DELETE /admin/users/:id(.:format)                                                  admin/users#destroy
#                      admin_accounts GET    /admin/accounts(.:format)                                                   admin/accounts#index
#                                     POST   /admin/accounts(.:format)                                                   admin/accounts#create
#                   new_admin_account GET    /admin/accounts/new(.:format)                                               admin/accounts#new
#                  edit_admin_account GET    /admin/accounts/:id/edit(.:format)                                          admin/accounts#edit
#                       admin_account GET    /admin/accounts/:id(.:format)                                               admin/accounts#show
#                                     PUT    /admin/accounts/:id(.:format)                                               admin/accounts#update
#                                     DELETE /admin/accounts/:id(.:format)                                               admin/accounts#destroy
#                   public_recipients GET    /public/recipients(.:format)                                                public/recipients#index
#                    public_recipient GET    /public/recipients/:id(.:format)                                            public/recipients#show
#                                     DELETE /public/recipients/:id(.:format)                                            public/recipients#destroy
#            start_account_newsletter GET    /accounts/:account_id/newsletters/:id/start(.:format)                       newsletters#start
#             stop_account_newsletter GET    /accounts/:account_id/newsletters/:id/stop(.:format)                        newsletters#stop
#                 account_newsletters GET    /accounts/:account_id/newsletters(.:format)                                 newsletters#index
#                                     POST   /accounts/:account_id/newsletters(.:format)                                 newsletters#create
#              new_account_newsletter GET    /accounts/:account_id/newsletters/new(.:format)                             newsletters#new
#             edit_account_newsletter GET    /accounts/:account_id/newsletters/:id/edit(.:format)                        newsletters#edit
#                  account_newsletter GET    /accounts/:account_id/newsletters/:id(.:format)                             newsletters#show
#                                     PUT    /accounts/:account_id/newsletters/:id(.:format)                             newsletters#update
#                                     DELETE /accounts/:account_id/newsletters/:id(.:format)                             newsletters#destroy
#           delete_account_recipients GET    /accounts/:account_id/recipients/delete(.:format)                           recipients#delete
# multiple_destroy_account_recipients DELETE /accounts/:account_id/recipients/multiple_destroy(.:format)                 recipients#multiple_destroy
#         account_recipient_send_outs GET    /accounts/:account_id/recipients/:recipient_id/send_outs(.:format)          send_outs#index
#                                     POST   /accounts/:account_id/recipients/:recipient_id/send_outs(.:format)          send_outs#create
#      new_account_recipient_send_out GET    /accounts/:account_id/recipients/:recipient_id/send_outs/new(.:format)      send_outs#new
#     edit_account_recipient_send_out GET    /accounts/:account_id/recipients/:recipient_id/send_outs/:id/edit(.:format) send_outs#edit
#          account_recipient_send_out GET    /accounts/:account_id/recipients/:recipient_id/send_outs/:id(.:format)      send_outs#show
#                                     PUT    /accounts/:account_id/recipients/:recipient_id/send_outs/:id(.:format)      send_outs#update
#                                     DELETE /accounts/:account_id/recipients/:recipient_id/send_outs/:id(.:format)      send_outs#destroy
#                  account_recipients GET    /accounts/:account_id/recipients(.:format)                                  recipients#index
#                                     POST   /accounts/:account_id/recipients(.:format)                                  recipients#create
#               new_account_recipient GET    /accounts/:account_id/recipients/new(.:format)                              recipients#new
#              edit_account_recipient GET    /accounts/:account_id/recipients/:id/edit(.:format)                         recipients#edit
#                   account_recipient GET    /accounts/:account_id/recipients/:id(.:format)                              recipients#show
#                                     PUT    /accounts/:account_id/recipients/:id(.:format)                              recipients#update
#                                     DELETE /accounts/:account_id/recipients/:id(.:format)                              recipients#destroy
#                      account_assets POST   /accounts/:account_id/assets(.:format)                                      assets#create
#                      account_charts GET    /accounts/:account_id/charts(.:format)                                      charts#index
#                            accounts GET    /accounts(.:format)                                                         accounts#index
#                           subscribe POST   /subscribe/:account_permalink(.:format)                                     public/recipients#create
#                             confirm GET    /confirm/:recipient_confirm_code(.:format)                                  public/recipients#confirm
#                         unsubscribe GET    /unsubscribe/:recipient_confirm_code(.:format)                              public/recipients#destroy_confirm
#                                     DELETE /unsubscribe/:recipient_confirm_code(.:format)                              public/recipients#destroy
#                                     DELETE /remove/:account_permalink(.:format)                                        public/recipients#destroy_by_email
#                          newsletter GET    /:recipient_id/:send_out_id(/:image)(.:format)                              public/newsletters#show
