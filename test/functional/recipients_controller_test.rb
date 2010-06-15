require 'test_helper'

class RecipientsControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user  = users(:biff)
    @recipient = recipients(:josh)
    @account = @recipient.account
    sign_in @user
  end

  test "should not get index with wrong account" do
    account = accounts(:admin_account)
    get :index, :account_id => account.to_param
    assert_response 404
  end

  test "should get index" do
    get :index, :account_id => @account.to_param
    assert_response :success
    assert_not_nil assigns(:recipients)
  end
  
  test "should get index if wrong account but admin" do
    sign_out @user
    sign_in @admin
    get :index, :account_id => @account.to_param
    assert_response :success
    assert_not_nil assigns(:recipients)
  end

  test "should get new" do
    get :new, :account_id => @account.to_param
    assert_response :success
  end

  test "should create recipient" do
    assert_difference('Recipient.count') do
      post :create, :account_id => @account.to_param, :recipient => @recipient.attributes.merge(:email => 'new@email.com')
    end

    assert_redirected_to account_recipients_path(@account)
  end

  test "should show recipient" do
    get :show, :account_id => @account.to_param, :id => @recipient.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :account_id => @account.to_param,:id => @recipient.to_param
    assert_response :success
  end

  test "should update recipient" do
    put :update, :account_id => @account.to_param, :id => @recipient.to_param, :recipient => @recipient.attributes
    assert_redirected_to account_recipients_path(@account)
  end

  test "should destroy recipient" do
    assert_difference('Recipient.count', -1) do
      delete :destroy, :account_id => @account.to_param, :id => @recipient.to_param
    end

    assert_redirected_to account_recipients_path(@account)
  end
end
