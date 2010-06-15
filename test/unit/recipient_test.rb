require 'test_helper'

class RecipientTest < ActiveSupport::TestCase

  test "unique email per account" do
    r = recipients(:josh)
    new_r = r.account.recipients.new(:email => "unique@email.com")
    assert new_r.valid?
    
    new_r = r.account.recipients.new(:email => r.email)
    assert !new_r.valid?
    
    account = accounts(:admin_account)
    new_r = account.recipients.new(:email => r.email)
    assert new_r.valid?
  end
  
  test "multiple account per email" do
    
  end
end
