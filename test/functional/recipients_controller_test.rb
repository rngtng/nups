require 'test_helper'

class RecipientsControllerTest < ActionController::TestCase
  setup do
    @recipient = recipients(:josh)
    @account = @recipient.account
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:recipients)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create recipient" do
    assert_difference('Recipient.count') do
      post :create, :recipient => @recipient.attributes
    end

    assert_redirected_to account_recipient_path(@account, assigns(:recipient))
  end

  test "should show recipient" do
    get :show, :id => @recipient.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @recipient.to_param
    assert_response :success
  end

  test "should update recipient" do
    put :update, :id => @recipient.to_param, :recipient => @recipient.attributes
    assert_redirected_to account_recipient_path(@account, assigns(:recipient))
  end

  test "should destroy recipient" do
    assert_difference('Recipient.count', -1) do
      delete :destroy, :id => @recipient.to_param
    end

    assert_redirected_to account_recipients_path(@account)
  end
end
