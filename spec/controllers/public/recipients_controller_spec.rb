require 'spec_helper'

describe Public::RecipientsController do
  fixtures :all #:accounts, :recipients, :users, :newsletters

  let(:account) { accounts(:biff_account) }
  let(:recipient) { recipients(:wonne) }

  describe "#create" do
    before do
      recipient.force_destroy
    end

    it "create recipient" do
      expect do
        post :create, :account_permalink => account.permalink, :recipient => recipient.attributes
      end.to change { account.reload.recipients.count }
    end

    it "creates prending recipient" do
      post :create, :account_permalink => account.permalink, :recipient => recipient.attributes
      Recipient.find_by_email(recipient.email).state.should == 'pending'
    end

    it "creates confirmed recipient" do
      post :create, :account_permalink => account.permalink, :recipient => recipient.attributes, :auto_confirm => true
      Recipient.find_by_email(recipient.email).state.should == 'confirmed'
    end

    it "is successful" do
      post :create, :account_permalink => account.permalink, :recipient => recipient.attributes
      response.status.should == 200
    end

    it "returns confirm_code" do
      post :create, :account_permalink => account.permalink, :recipient => { :email => recipient.email }, :format => :json
      response.body.should include(assigns(:recipient).confirm_code)
    end

    it "wrong account" do
      post :create, :account_permalink => 'unasd'
      response.status.should == 404
    end

    context "json format" do
      it "is successful" do
        post :create, :account_permalink => account.permalink, :recipient => recipient.attributes, :format => :json
        response.status.should == 201
      end

      it "returns confirm_code" do
        post :create, :account_permalink => account.permalink, :recipient => { "email" => recipient.email }, :format => :json
        response.body.should == %|{"confirm_path":"/confirm/#{assigns(:recipient).confirm_code}"}|
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
  end

  describe "#destroy_confirm" do
    it "is successful" do
      get :destroy_confirm, :recipient_confirm_code => recipient.confirm_code
      response.status.should == 200
    end

    it "is successful" do
      get :destroy_confirm, :recipient_confirm_code => recipient.confirm_code
      assigns(:recipient).should == recipient
    end
  end

  describe "#destroy" do
    it "is successful" do
      delete :destroy, :recipient_confirm_code => recipient.confirm_code
      response.status.should == 200
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