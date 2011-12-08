require 'spec_helper'

describe NewslettersController do
  include Devise::TestHelpers

  fixtures :all

  let(:admin) { users(:admin) }
  let(:user) { users(:biff) }
  let(:newsletter) { newsletters(:biff_newsletter) }
  let(:account) { newsletter.account }

  context "logged out" do
    it "should not get index" do
      get :index, :account_id => account.to_param
      response.status.should == 302
    end

    it "should not get new" do
      get :new, :account_id => account.to_param
      response.status.should == 302
    end

    it "should not get show" do
      get :show, :account_id => account.to_param, :id => newsletter.id
      response.status.should == 302
    end
  end

  context "logged in" do
    before do
      sign_in user
    end

    it "should get index" do
      get :index, :account_id => account.to_param
      response.status.should == 200 #:success
      assigns(:newsletters).should_not be_nil
    end

    context "as admin" do
      before do
        sign_out user
        sign_in admin
      end

      it "sees all newsletter for other user" do
        get :index, :user_id => user.id
        assigns(:newsletters).size.should == 2
      end
    end

    it "should get stats" do
      get :stats, :account_id => account.to_param, :format => :js
      response.status.should == 200 #:success
      assigns(:newsletters).should_not be_nil
    end

    describe "new" do
      it "should get new" do
        get :index, :account_id => account.to_param
        response.status.should == 200 #:success
      end

      it "should not get new if wrong account" do
        account = accounts(:admin_account)
        get :new, :account_id => account.to_param
        response.status.should == 404
      end

      it "should get new if wrong account but admin" do
        sign_in admin
        get :new, :account_id => account.to_param
        assigns(:newsletter).subject.should == account.subject
        response.status.should == 200 #:success
      end
    end

    describe "show" do
      context "html" do
        before do
          xhr :get, :show, :account_id => account.to_param, :id => newsletter.to_param
        end

        it "assigns newsletter" do
          assigns(:newsletter).id.should == newsletter.id
        end

        it "response valid" do
          response.status.should == 200 #:success
        end
      end

      it "returns newletter hmtl content" do
        xhr :get, :show, :account_id => account.to_param, :id => newsletter.to_param
        response.body.should == newsletter.content + "<img src=\"http://localhost/0/0.gif\" width=\"1\" height=\"1\">"
      end
    end

    describe "create" do
      it "creates newsletter" do
        expect do
          post :create, :account_id => account.to_param, :newsletter => newsletter.attributes
        end.to change(Newsletter, :count)
      end

      it "creates newsletter with empty attachment_ids" do
        expect do
          post :create, :account_id => account.to_param, :newsletter => {:subject => "blabla", :attachment_ids => ["1"]}
        end.to change(Newsletter, :count)
      end

      it "redirects to newsletters form account" do
        post :create, :account_id => account.to_param, :newsletter => newsletter.attributes
        response.should redirect_to(account_newsletters_path(account))
      end
    end

    describe "edit" do
      it "does success" do
        get :edit, :account_id => account.to_param, :id => newsletter.to_param
        response.status.should == 200 #:success
      end
    end

    describe "update" do
      it "should update newsletter" do
        put :update, :account_id => account.to_param, :id => newsletter.to_param, :newsletter => newsletter.attributes
        response.should redirect_to(account_newsletters_path(account))
      end
    end

    describe "destroy" do
      it "should destroy newsletter" do
        expect do
          delete :destroy, :account_id => account.to_param, :id => newsletter.to_param
        end.to change(Newsletter, :count).by(-1)
      end

      it "should redirect to newsletters from account" do
        delete :destroy, :account_id => account.to_param, :id => newsletter.to_param
        response.should redirect_to(account_newsletters_path(account))
      end
    end

    describe "schedule" do
      it "should change newsletter state" do
        get :start, :account_id => account.to_param, :id => newsletter.to_param
        newsletter.reload.testing?.should be_true
      end

      it "should queue test newsletter" do
        get :start, :account_id => account.to_param, :id => newsletter.to_param
        Newsletter.should have_queued(newsletter.id, "_send_test!")
      end

      it "should queue live newsletter" do
        get :start, :account_id => account.to_param, :id => newsletter.to_param, :mode => 'live'
        Newsletter.should have_queued(newsletter.id, "_send_live!")
      end

      it "should redirect to newsletters from account" do
        get :start, :account_id => account.to_param, :id => newsletter.to_param
        response.should redirect_to(account_newsletters_path(account))
      end
    end

  end

=begin
    it "admin should be able to create newsletter for other user" do
      expect do
        post :create, :account_id => account.to_param, :newsletter => newsletter.attributes, :preview => true
      end.to change(Newsletter, :count)
      assert_redirected_to account_newsletter_path(account, assigns(:newsletter))
    end
  end
=end

end
