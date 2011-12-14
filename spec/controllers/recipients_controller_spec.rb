require 'spec_helper'

describe RecipientsController do
  include Devise::TestHelpers

  fixtures :all #:accounts, :recipients, :users, :newsletters

  let(:admin) { users(:admin) }
  let(:user) { users(:biff) }
  let(:recipient) { recipients(:josh) }
  let(:account) { accounts(:biff_account) }

  before do
    sign_in user
  end

  describe "index" do
    render_views
    it "does not get index with wrong account" do
      get :index, :account_id => accounts(:admin_account).to_param
      response.status.should ==  404
    end

    it "gets index" do
      get :index, :account_id => account.to_param
      response.status.should ==  200 #:success
    end

    it "assigns recipients" do
      get :index, :account_id => account.to_param
      assigns(:recipients).should be_present
    end

    it "gets index and find by given search token" do
      account.recipients.size.should > 1
      get :index, :account_id => account.to_param, :search => account.recipients.confirmed.first.email
      response.status.should == 200 #:success
    end

    it "assigns recipients by given search token" do
      account.recipients.size.should > 1
      get :index, :account_id => account.to_param, :search => account.recipients.confirmed.first.email
      assigns(:recipients).size.should == 1
    end

    #it "gets index with excel" do
    #  account = accounts(:admin_account)
    #  get :index, :account_id => account.to_param, :format => :xls
    #  response.status.should ==  :success
    #  assert_not_nil assigns(:recipients)
    #end

    context "as admin" do
      before do
        sign_in admin
      end

      it "gets index if wrong account but admin" do
        get :index, :account_id => account.to_param
        response.status.should ==  200 #:success
        assigns(:recipients).should be_present
      end

      it "assigns recipients" do
        get :index, :account_id => account.to_param
        assigns(:recipients).should be_present
      end
    end
  end

  describe "new" do
    render_views
    it "gets new" do
      get :new, :account_id => account.to_param
      response.status.should ==  200 #:success
    end
  end

  describe "create" do
    render_views
    let(:emails) { "valid@email1.de,invalid" }

    it "creates valid recipient" do
      expect do
        post :create, :account_id => account.to_param, :emails => emails
      end.to change { account.recipients.count }.by(1)
    end

    context "with already peding recipient" do
      let(:recipient) { account.recipients.create( :email => "valid@email1.de" ) }

      it "re-confirms" do
        expect do
          post :create, :account_id => account.to_param, :emails => recipient.email
        end.to change { recipient.reload.state }.from('pending').to('confirmed')
      end
    end

    context "with already deleted recipient" do
      let(:recipient) { account.recipients.confirmed.first }

      it "re-confirms" do
        recipient.destroy
        expect do
          post :create, :account_id => account.to_param, :emails => recipient.email
        end.to change { recipient.reload.state }.from('deleted').to('confirmed')
      end
    end

    it "returns valid/invalid adresses for xhr" do
      xhr :post, :create, :account_id => account.to_param, :emails => emails
      response.body.should == "{\"valid\":[\"valid@email1.de\"],\"invalid\":[\"invalid\"]}"
    end

    it "assigns valids" do
      post :create, :account_id => account.to_param, :emails => emails
      assigns(:valid_recipients).map(&:email).should == ['valid@email1.de']
    end

    it "assigns invalids" do
      post :create, :account_id => account.to_param, :emails => emails
      assigns(:invalid_recipients).map(&:email).should == ['invalid']
    end
  end

  describe "update" do
    it "updates recipient" do
      put :update, :account_id => account.to_param, :id => recipient.to_param, :recipient => recipient.attributes
      response.should redirect_to(account_recipients_path(account))
    end
  end

  describe "destroy" do
    it "destroys recipient" do
      expect do
        delete :destroy, :account_id => account.to_param, :id => recipient.to_param
      end.to change { account.recipients.confirmed.count }.by(-1)
    end

    it "destroys recipient" do
      delete :destroy, :account_id => account.to_param, :id => recipient.to_param
      response.should redirect_to(account_recipients_path(account))
    end
  end

  describe "delete" do
    it "shows multiple delete" do
      get :delete, :account_id => account.to_param
      response.status.should ==  200 #:success
    end
  end

  describe "split_emails" do
    it "splits email string" do
      string = "1\n2\n,,3,'4';\"5\""
      @controller.send(:split_emails, string).map(&:to_i).should =~ Array(1..5)
    end
  end

  describe "multiple_destroy" do
    let(:existing_email) { account.recipients.confirmed.first.email }
    let(:emails) { "#{existing_email}\n\tvalid@email1.de,invalid" }

    it "shows existing and valid adresses" do
      expect do
        post :multiple_destroy, :account_id => account.to_param, :emails => emails
      end.to_not change { account.recipients.confirmed.count }
    end

    it "redirect if not xhr" do
      post :multiple_destroy, :account_id => account.to_param, :emails => emails
      response.should redirect_to(account_recipients_url)
    end

    it "redirect if not xhr" do
      xhr :post, :multiple_destroy, :account_id => account.to_param, :emails => emails
      response.body.should == "{\"valid\":[\"#{existing_email}\"],\"invalid\":[\"valid@email1.de\",\"invalid\"],\"delete\":null}"
    end

    context "delete given" do
      it "deletes existing valid adresses" do
        expect do
          post :multiple_destroy, :account_id => account.to_param, :emails => emails, :delete => true
        end.to change { account.recipients.confirmed.count }.by(-1)
      end
    end
  end
end