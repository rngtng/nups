# == Schema Info
#
# Table name: recipients
#
#  id               :integer(4)      not null, primary key
#  account_id       :integer(4)
#  bounces          :text            not null, default("")
#  bounces_count    :integer(4)      not null
#  deliveries_count :integer(4)      not null
#  email            :string(255)
#  first_name       :string(255)
#  gender           :string(255)
#  last_name        :string(255)
#  created_at       :datetime
#  updated_at       :datetime

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