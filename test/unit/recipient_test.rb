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
  
  test "search should find exactly one" do
    account = accounts(:biff_account)
    recipient = account.recipients.first
    
    assert account.recipients.size > 1  #make sure we have more than one, otherwise rest of test is senseless ;-)
    
    Recipient::SEARCH_COLUMNS.each do |column|
      search_token = recipient.send(column)
      assert_equal 1, account.recipients.search(search_token).size
      assert_equal 1, account.recipients.search(search_token[0..-2]).size  #remove last char
      assert_equal 1, account.recipients.search(search_token[1..-1]).size  #remove first char
    end
  end

  #test "multiple account per email" do
  #  
  #end
  
end

# == Schema Info
#
# Table name: recipients
#
#  id               :integer(4)      not null, primary key
#  account_id       :integer(4)
#  bounces          :text
#  bounces_count    :integer(4)      not null, default(0)
#  deliveries_count :integer(4)      not null, default(0)
#  email            :string(255)
#  first_name       :string(255)
#  gender           :string(255)
#  last_name        :string(255)
#  created_at       :datetime
#  updated_at       :datetime