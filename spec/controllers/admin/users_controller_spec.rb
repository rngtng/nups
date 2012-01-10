require 'spec_helper'

describe Admin::UsersController do
  include Devise::TestHelpers

  fixtures :all

  let(:admin) { users(:admin) }
  let(:user) { users(:biff) }
  let(:user_attributes) { attributes_for(:user) }

  before do
    sign_in admin
  end

  describe "#index" do
    it "gets index" do
      get :index
      response.status.should == 200
    end

    it "gets index" do
      get :index
      assigns(:users).should be_present
    end

    it "denys access to normal user" do
      sign_out admin

      #change user to NON admin
      sign_in user
      get :index
      response.status.should == 403 # :forbidden
    end
  end

  describe "#new" do
    it "gets new" do
      get :new
      response.status.should == 200
    end
  end

  describe "#create" do
    it "create user" do
     expect do
       post :create, :user => user_attributes
     end.to change { User.count }
    end
     # response.should redirect_to(admin_user_path(user))
   end

  describe "#show" do
    it "shows user" do
      get :show, :id => user.to_param
      response.status.should == 200
    end
  end

  describe "#edit" do
    it "gets edit" do
      get :edit, :id => user.to_param
      response.status.should == 200
    end
  end

  describe "#update" do
    it "updates user" do
      put :update, :id => user.to_param, :user => user_attributes
      response.should redirect_to(admin_user_path(user))
    end

    it "changes email" do
      expect do
        put :update, :id => user.to_param, :user => user_attributes
      end.to change { user.reload.email }
    end
  end

  describe "#destroy" do
    it "destroys user" do
      expect do
        delete :destroy, :id => user.to_param
      end.to change { User.count }.by(-1)
    end

    it "redirects" do
      delete :destroy, :id => user.to_param
      response.should redirect_to(admin_users_path)
    end
  end
end
