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

    describe "new" do
      it "should get new" do
        get :index, :account_id => account.to_param
        response.status.should == 200 #:success
      end

      it "should not get new if wrong account" do
        account = accounts(:admin_account)
        get :new, :account_id => account.to_param
        response.status.should == 403 #:success
      end

      it "should get new if wrong account but admin" do
        sign_in admin
        get :new, :account_id => account.to_param
        assigns(:newsletter).subject.should == account.subject
        response.status.should == 200 #:success
      end
    end

    describe "show" do
      it "should show newsletter" do
        get :show, :account_id => account.to_param, :id => newsletter.to_param
        response.status.should == 200 #:success
      end
    end

    describe "create" do
      it "should create newsletter" do
        expect do
          post :create, :account_id => account.to_param, :newsletter => newsletter.attributes, :preview => true
        end.to change(Newsletter, :count)
        response.should redirect_to(account_newsletter_path(account, newsletter))
      end
    end

    describe "edit" do
      it "should get edit" do
        get :edit, :account_id => account.to_param, :id => newsletter.to_param
        response.status.should == 200 #:success
      end
    end

    describe "update" do
      it "should update newsletter" do
        put :update, :account_id => account.to_param, :id => newsletter.to_param, :newsletter => newsletter.attributes
        response.should redirect_to(account_newsletters_path(account))
      end

      it "should update newsletter and preview" do
        put :update, :account_id => account.to_param, :id => newsletter.to_param, :newsletter => newsletter.attributes, :preview => true
        response.should redirect_to(account_newsletter_path(*newsletter.route))
      end
    end

    describe "destroy" do
      it "should destroy newsletter" do
        expect do
          delete :destroy, :account_id => account.to_param, :id => newsletter.to_param
        end.to change(Newsletter, :count).by(-1)

        response.should redirect_to(newsletters_path)
      end
    end

    describe "schedule" do
      it "should change newsletter state" do
        get :start, :account_id => account.to_param, :id => newsletter.to_param
        newsletter.reload.testing?.should be_true
      end

      it "should create test newsletter sendout" do
        expect do
          with_resque do
            get :start, :account_id => account.to_param, :id => newsletter.to_param
          end
        end.to change(TestSendOut, :count).by(2)
        # puts newsletter.test_send_outs.all.map &:inspect

        TestSendOut.last.sheduled?.should be_true

        response.should redirect_to(account_newsletters_path(account))
      end

      it "should schedule live newsletter" do
        expect do
#          with_resque do
            get :start, :account_id => account.to_param, :id => newsletter.to_param, :mode => 'live'
 #         end
        end.to change(LiveSendOut, :count).by(newsletter.recipients.count)

        LiveSendOut.last.sheduled?.should be_true

        response.should redirect_to(account_newsletters_path(account))
      end
    end

  end

=begin

    it "admin should see newsletter for other user" do
      sign_out @user
      sign_in @admin

      post :index, :account_id => account.to_param

      assert_equal 2, assigns(:newsletters).size
    end

    it "admin should see all newsletter for other user" do
      sign_out @user
      sign_in @admin

      post :index, :user_id => @user.id

      assert_equal 2, assigns(:newsletters).size
    end

    it "admin should be able to create newsletter for other user" do
      sign_out @user
      sign_in @admin

      expect do
        post :create, :account_id => account.to_param, :newsletter => newsletter.attributes, :preview => true
      end.to change(Newsletter, :count)
      assert_redirected_to account_newsletter_path(account, assigns(:newsletter))
    end
  end
=end

end
