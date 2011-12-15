require 'spec_helper'

describe ChartsController do
  include Devise::TestHelpers

  fixtures :all

  let(:user) { users(:biff) }

  before do
    sign_in user
  end

  describe "index" do
    render_views

    it "is success" do
      get :index, :account_id => accounts(:biff_account)
      response.status.should == 200
    end
  end
end
