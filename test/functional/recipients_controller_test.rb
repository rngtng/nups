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

  test "should get index with excel" do
    account = accounts(:admin_account)
    get :index, :account_id => account.to_param, :format => :xls
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
    assert_difference('@account.recipients.count') do
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
    assert_difference('@account.recipients.count', -1) do
      delete :destroy, :account_id => @account.to_param, :id => @recipient.to_param
    end

    assert_redirected_to account_recipients_path(@account)
  end
  
  test "should show import" do
    get :import, :account_id => @account.to_param
    assert_response :success
  end

  test "should show valid/invalid adresses" do
    assert_no_difference('@account.recipients.count') do
      post :import, :account_id => @account.to_param, :emails => "valid@email1.de,invalid"
    end
    assert_equal 1, assigns(:valid_recipients).count
    assert assigns(:valid_recipients).first.new_record?
    assert assigns(:valid_recipients).first.valid?
    
    assert_equal 1, assigns(:invalid_recipients).count
    assert assigns(:invalid_recipients).first.new_record?
    assert !assigns(:invalid_recipients).first.valid?
    
    assert_response :success
  end

  test "should import valid adresses" do
    assert_difference('@account.recipients.count') do
      post :import, :account_id => @account.to_param, :emails => "valid@email1.de\ninvalid", :import => true
    end

    assert_equal 1, assigns(:valid_recipients).count
    assert !assigns(:valid_recipients).first.new_record?
    assert assigns(:valid_recipients).first.valid?
    
    assert_equal 1, assigns(:invalid_recipients).count
    assert assigns(:invalid_recipients).first.new_record?    
    assert !assigns(:invalid_recipients).first.valid?
    
    assert_response :success
  end

  test "should show multiple delete" do
    get :multiple_delete, :account_id => @account.to_param
    assert_response :success
  end

  test "should show existing and valid adresses" do
    existing_email = @account.recipients.first.email
    assert_no_difference('@account.recipients.count') do
      post :multiple_delete, :account_id => @account.to_param, :emails => "#{existing_email}\n\tvalid@email1.de,invalid"
    end
    
    assert_equal 1, assigns(:valid_recipients).count
    assert_equal existing_email, assigns(:valid_recipients).first.email
    
    assert_equal 2, assigns(:invalid_recipients).count
    assert assigns(:invalid_recipients).first.new_record?
    assert assigns(:invalid_recipients).first.valid?

    assert assigns(:invalid_recipients).last.new_record?
    assert !assigns(:invalid_recipients).last.valid?
    
    assert_response :success
  end

  test "should delete existing valid adresses" do
    existing_email = @account.recipients.first.email
    assert_difference('@account.recipients.count', -1) do
      post :multiple_delete, :account_id => @account.to_param, :emails => "#{existing_email}\nvalid@email1.de;invalid", :delete => true
    end

    assert_equal 1, assigns(:valid_recipients).count
    assert_equal existing_email, assigns(:valid_recipients).first.email
    
    assert_equal 2, assigns(:invalid_recipients).count
    assert assigns(:invalid_recipients).first.new_record?
    assert assigns(:invalid_recipients).first.valid?

    assert assigns(:invalid_recipients).last.new_record?
    assert !assigns(:invalid_recipients).last.valid?
    
    assert_response :success
  end
  
  test "should split email string" do
   string = "1\n2\n,,3,'4';\"5\""
   assert_equal Array(1..5), @controller.send(:split_emails, string).map(&:to_i) #string <-> integer
  end
  
end
