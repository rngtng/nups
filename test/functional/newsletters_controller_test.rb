require 'test_helper'

class NewslettersControllerTest < ActionController::TestCase
  setup do
    @admin = users(:admin)
    @user = users(:biff)
    @newsletter = newsletters(:biff_newsletter)
    @account = @newsletter.account
    sign_in @user
  end

  test "should not get index if logged out" do
    sign_out @user
    get :index
    assert_response 302
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:newsletters)
  end

  test "should not get new if wrong account" do
    account = accounts(:admin_account)
    get :new, :account_id => account.to_param
    assert_response 403
  end

  test "should get new if wrong account but admin" do
    sign_out @user
    sign_in @admin
    get :new, :account_id => @account.to_param
    assert_equal @account.subject, assigns(:newsletter).subject
    assert_response :success
  end


  test "should get new" do
    get :new, :account_id => @account.to_param
    assert_response :success
  end
  
  test "should create newsletter" do
    assert_difference('Newsletter.count') do
      post :create, :account_id => @account.to_param, :newsletter => @newsletter.attributes, :preview => true
    end
    assert_redirected_to account_newsletter_path(@account, assigns(:newsletter))
  end

  test "should show newsletter" do
    get :show, :account_id => @account.to_param, :id => @newsletter.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :account_id => @account.to_param, :id => @newsletter.to_param
    assert_response :success
  end

  test "should update newsletter" do
    put :update, :account_id => @account.to_param, :id => @newsletter.to_param, :newsletter => @newsletter.attributes
    assert_redirected_to account_newsletters_path(@account)
  end

  test "should update newsletter and preview" do
    put :update, :account_id => @account.to_param, :id => @newsletter.to_param, :newsletter => @newsletter.attributes, :preview => true
    assert_redirected_to account_newsletter_path(*assigns(:newsletter).route)
  end

  test "should destroy newsletter" do
    assert_difference('Newsletter.count', -1) do
      delete :destroy, :account_id => @account.to_param, :id => @newsletter.to_param
    end

    assert_redirected_to newsletters_path
  end
end
