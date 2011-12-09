require 'spec_helper'

describe Admin::AccountsController do
  include Devise::TestHelpers

  fixtures :all

  let(:admin) { users(:admin) }
  let(:account) { admin.accounts.first }

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
      assigns(:accounts).should be_present
    end

    it "denys access to normal user" do
      sign_out admin

      #change user to NON admin
      sign_in users(:biff)
      get :index
      response.status.should == 403 #:forbidden
    end
  end

  describe "#new" do
    it "gets new" do
      get :new
      response.status.should == 200
    end
  end

  describe "#create" do
    before do
      account.destroy
    end

    it "creates account" do
      expect do
        post :create, :account => account.attributes
      end.to change { Account.count }
    end

    it "redirects to index" do
      post :create, :account => account.attributes
      response.should redirect_to(admin_accounts_path)
    end
  end

  describe "#show" do
    it "shows account" do
      get :show, :id => account.to_param
      response.status.should == 200
    end
  end

  describe "#edit" do
    it "gets edit" do
      get :edit, :id => account.to_param
      response.status.should == 200
    end
  end

  describe "#update" do
    it "updates account" do
      put :update, :id => account.to_param, :account => account.attributes
      response.should redirect_to(admin_accounts_path)
    end
  end

  describe "#destroy" do
    it "destroys account" do
      expect do
        delete :destroy, :id => account.to_param
      end.to change { Account.count }.by(-1)
    end

    it "redirects" do
      delete :destroy, :id => account.to_param
      response.should redirect_to(admin_accounts_path)
    end
  end
end
