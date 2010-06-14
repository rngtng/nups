require 'test_helper'

class RecipientTest < ActiveSupport::TestCase

  test "unique email per account" do
    r = recipients(:josh)
    new_r = Recipient.new(:email => "unique@email.com")
    r.account.recipients << new_r
    assert new_r.valid?
    
    new_r = Recipient.new(:email => r.email)
    r.account.recipients << new_r
    assert !new_r.valid?
    
    account = accounts(:one)
    new_r = Recipient.new(:email => r.email)
    account.recipients << new_r
    assert new_r.valid?
  end
  
  test "multiple account per email" do
    
  end
end
