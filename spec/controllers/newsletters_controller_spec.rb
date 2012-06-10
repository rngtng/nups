require 'spec_helper'

describe NewslettersController do
  include Devise::TestHelpers

  fixtures :accounts, :users, :newsletters

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
    render_views

    before do
      sign_in user
    end

    describe "index" do
      it "is success" do
        get :index, :account_id => account.to_param
        response.status.should == 200 #:success
      end

      it "assigns newsletters" do
        get :index, :account_id => account.to_param
        assigns(:newsletters).should =~ account.newsletters
      end

      it "gets not index for other user account" do
        get :index, :account_id => accounts(:admin_account).to_param
        response.status.should == 404
      end

      it "sees all own newsletters" do
        get :index
        assigns(:newsletters).should =~ user.newsletters
      end

      context "as admin" do
        before do
          sign_in admin
        end

        it "sees all newsletter for other user" do
          get :index, :user_id => user.id
          assigns(:newsletters).should =~ user.newsletters
        end

        it "gets index for other user account" do
          get :index, :account_id => account.to_param
          assigns(:newsletters).should =~ account.newsletters
        end
      end
    end

    describe "stats" do
      it "should get stats" do
        get :stats, :account_id => account.to_param, :format => :js
        response.status.should == 200 #:success
        assigns(:newsletters).should_not be_nil
      end
    end

    describe "new" do
      it "should get new" do
        get :index, :account_id => account.to_param
        response.status.should == 200 #:success
      end

      it "doesn't get new if wrong account" do
        account = accounts(:admin_account)
        get :new, :account_id => account.to_param
        response.status.should == 404 #:not_found
      end

      it "gets new if wrong account but admin" do
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

      it "returns newletter html content" do
        xhr :get, :show, :account_id => account.to_param, :id => newsletter.to_param
        response.body.should include(newsletter.content)
      end
    end

    describe "#create" do
      it "creates newsletter" do
        expect do
          post :create, :account_id => account.to_param, :newsletter => newsletter.attributes
        end.to change { Newsletter.count }
      end

      it "creates newsletter with empty attachment_ids" do
        expect do
          post :create, :account_id => account.to_param, :newsletter => {:subject => "blabla", :attachment_ids => ["1"]}
        end.to change { Newsletter.count }
      end

      it "redirects to newsletters form account" do
        post :create, :account_id => account.to_param, :newsletter => newsletter.attributes
        response.should redirect_to(account_newsletters_path(account))
      end

      context "as admin" do
        before do
          sign_in admin
        end

        it "creates newsletter for other user" do
          expect do
            post :create, :account_id => account.to_param, :newsletter => newsletter.attributes, :preview => true
          end.to change { account.newsletters.count }
        end
      end
    end

    describe "#edit" do
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
      context "test" do
        it "changes newsletter state" do
          get :start, :account_id => account.to_param, :id => newsletter.to_param
          newsletter.reload.pre_testing?.should be_true
        end

        it "queues test newsletter" do
          get :start, :account_id => account.to_param, :id => newsletter.to_param
          Newsletter.should have_queued(newsletter.id, "_send_test!", user.email)
        end

        it "redirects to newsletters from account" do
          get :start, :account_id => account.to_param, :id => newsletter.to_param
          response.should redirect_to(account_newsletters_path(account))
        end
      end

      context "live" do
        it "changes newsletter state" do
          get :start, :account_id => account.to_param, :id => newsletter.to_param, :mode => 'live'
          newsletter.reload.pre_sending?.should be_true
        end

        it "queues live newsletter" do
          get :start, :account_id => account.to_param, :id => newsletter.to_param, :mode => 'live'
          Newsletter.should have_queued(newsletter.id, "_send_live!")
        end
      end
    end

  end
end
