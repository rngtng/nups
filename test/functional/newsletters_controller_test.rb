require 'test_helper'

class NewslettersControllerTest < ActionController::TestCase
  setup do
    sign_in users(:biff)
    @newsletter = newsletters(:biff_newsletter)
    @account = @newsletter.account
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:newsletters)
  end

  test "should get new" do
    get :new, :account_id => @account.to_param
    assert_response :success
  end

  test "should create newsletter" do
    assert_difference('Newsletter.count') do
      post :create, :account_id => @account.to_param, :newsletter => @newsletter.attributes
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
    assert_redirected_to account_newsletter_path(@account, assigns(:newsletter))
  end

  test "should destroy newsletter" do
    assert_difference('Newsletter.count', -1) do
      delete :destroy, :account_id => @account.to_param, :id => @newsletter.to_param
    end

    assert_redirected_to newsletters_path
  end
end
