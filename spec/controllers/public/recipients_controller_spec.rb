require 'spec_helper'

describe Public::RecipientsController do
  fixtures :all #:accounts, :recipients, :users, :newsletters

  describe "#index" do
    it "is successful" do
      get :index
      response.status.should == 200
    end
  end

  describe "#show" do
    let(:account) { accounts(:biff_account) }
    let(:recipient) { account.recipients.first }

    before do
      get :show, :account_id => account.id, :id => recipient.id
    end

    it "is successful" do
      response.status.should == 200
    end

    it "is assign account" do
      assigns(:account).should == account
    end

    it "is assign recipient" do
      assigns(:recipient).should == recipient
    end

    context "wrong recipient" do
      let(:recipient) { recipients(:admin) }

      it "is not successful" do
        response.status.should == 404
      end

      it "does not assign recipient" do
        assigns(:recipient).should == nil
      end
    end
  end

  describe "#new" do
    let(:account) { accounts(:biff_account) }

    before do
      get :new, :account_permalink => account.permalink
    end

    it "is successful" do
      response.status.should == 200
    end

    it "is assign account by permalink" do
      assigns(:account).should == account
    end
  end
end