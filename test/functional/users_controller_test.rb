require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do    
    @admin = users(:admin)
    sign_in @admin
    
    @user = users(:biff)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  # test "should create user" do
  #   assert_difference('User.count') do
  #     post :create, :user => @user.attributes.merge( :email => "New@localhost.com", :password => "testest")
  #   end
  # 
  #   assert_redirected_to user_path(assigns(:user))
  # end

  test "should show user" do
    get :show, :id => @user.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @user.to_param
    assert_response :success
  end

  test "should update user" do
    put :update, :id => @user.to_param, :user => @user.attributes
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => @user.to_param
    end

    assert_redirected_to users_path
  end
  
  test "should deny access to normal user" do
    sign_out @admin
    
    #change user to NON admin
    sign_in @user
    get :index
    assert_response 403
  end  
end
