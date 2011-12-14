require 'spec_helper'

describe Public::RecipientsController do
  fixtures :all #:accounts, :recipients, :users, :newsletters

  let(:account) { accounts(:biff_account) }
  let(:recipient) { recipients(:wonne) }

  describe "#create" do
    let(:email) { "new@user.com" }
    let(:request_opts) do
      { :account_permalink => account.permalink, :recipient => { :email => email } }
    end

    it "create recipient" do
      expect do
        post :create, request_opts
      end.to change { account.reload.recipients.count }
    end

    it "creates prending recipient" do
      post :create, request_opts
      account.recipients.find_by_email(email).state.should == 'pending'
    end

    it "creates confirmed recipient" do
      post :create, request_opts.merge(:auto_confirm => true)
      account.recipients.find_by_email(email).state.should == 'confirmed'
    end

    context "email already in system" do
      before do
        recipient.destroy
      end

      it "creates pending recipient" do
        expect do
          post :create,  { :account_permalink => account.permalink, :recipient => { :email => recipient.email } }
        end.to change { recipient.reload.state }.from('deleted').to('pending')
      end

      it "creates confirmed recipient" do
        expect do
          post :create,  { :account_permalink => account.permalink, :recipient => { :email => recipient.email  }, :auto_confirm => true }
        end.to change { recipient.reload.state }.from('deleted').to('confirmed')
      end
    end

    it "is successful" do
      post :create, request_opts
      response.status.should == 200
    end

    it "returns confirm_code" do
      post :create, request_opts.merge(:format => :json)
      response.body.should include(assigns(:recipient).confirm_code)
    end

    it "wrong account" do
      post :create, :account_permalink => 'unasd'
      response.status.should == 404
    end

    context "json format" do
      it "is successful" do
        post :create,  request_opts.merge(:format => :json)
        response.status.should == 201
      end

      it "returns confirm_code" do
        post :create, request_opts.merge(:format => :json)
        response.body.should == %|{"confirm_path":"/confirm/#{assigns(:recipient).confirm_code}"}|
      end
    end

    context "recipient exists" do
      it "is not successful" do
        post :create, :account_permalink => account.permalink, :recipient => { :email => recipient.email }, :format => :json
        response.status.should == 422
      end

      it "create recipient" do
        expect do
          post :create, :account_permalink => account.permalink, :recipient => { :email => recipient.email }
        end.to_not change { account.reload.recipients.count }
      end
    end

    context "recipient is deleted" do
      it "is successful" do
        recipient.destroy
        post :create, :account_permalink => account.permalink, :recipient => { :email => recipient.email }, :format => :json
        response.status.should == 201
      end
    end
  end

  describe "#confirm" do
    let(:recipient) { recipients(:raziel) } #pending

    it "confirms recipient" do
      expect do
        get :confirm, :recipient_confirm_code => recipient.confirm_code
      end.to change { recipient.reload.state }.from('pending').to('confirmed')
    end

    it "wrong recipient" do
      get :confirm, :recipient_confirm_code => 'unasd'
      response.status.should == 404
    end

    context "json format" do
      it "returns email" do
        get :confirm, :recipient_confirm_code => recipient.confirm_code, :format => :json
        response.body.should == %|{"email":"#{recipient.email}"}|
      end
    end
  end

  describe "#destroy_confirm" do
    render_views

    it "is successful" do
      get :destroy_confirm, :recipient_confirm_code => recipient.confirm_code
      response.status.should == 200
    end

    it "is successful" do
      get :destroy_confirm, :recipient_confirm_code => recipient.confirm_code
      assigns(:recipient).should == recipient
    end
  end

  describe "#destroy_by_email" do
    it "is successful" do
      delete :destroy_by_email, :account_permalink => recipient.account.permalink, :email => recipient.email
      response.status.should == 200
    end

    it "is successful with json" do
      delete :destroy_by_email, :account_permalink => recipient.account.permalink, :email => recipient.email, :format => :json
      response.status.should == 200
    end

    it "destroys recipient" do
      expect do
        delete :destroy_by_email, :account_permalink => recipient.account.permalink, :email => recipient.email
      end.to change { account.recipients.confirmed.count }.by(-1)
    end

    it "changes recipient state" do
      expect do
        delete :destroy_by_email, :account_permalink => recipient.account.permalink, :email => recipient.email
      end.to change { recipient.reload.state }.from('confirmed').to('deleted')
    end

    it "not found on wrong recep" do
      delete :destroy_by_email, :account_permalink => recipient.account.permalink, :email => "asd@asd.de"
      response.status.should == 404
    end
  end

  describe "#destroy" do
    it "is successful" do
      delete :destroy, :recipient_confirm_code => recipient.confirm_code
      response.status.should == 200
    end

    it "not found for already deleted recipient" do
      recipient.destroy
      delete :destroy, :recipient_confirm_code => recipient.confirm_code
      response.status.should == 404
    end

    it "destroys recipient" do
      expect do
        delete :destroy, :recipient_confirm_code => recipient.confirm_code
      end.to change { account.recipients.confirmed.count }.by(-1)
    end

    it "changes recipient state" do
      expect do
        delete :destroy, :recipient_confirm_code => recipient.confirm_code
      end.to change { recipient.reload.state }.from('confirmed').to('deleted')
    end
  end
end