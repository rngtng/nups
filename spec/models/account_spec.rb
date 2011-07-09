require 'spec_helper'

describe Account do
  fixtures :all

  context "#test_recipient_emails_array" do
    {
      :by_comma => "test@test.de,test2@test.de,test3@test.de",
      :by_spec_char => "test@test.de;test2@test.de|test3@test.de",
      :uniq => "test@test.de,test2@test.de,test3@test.de,test3@test.de",
      :remove_empty => "test@test.de,,test2@test.de,test3@test.de,",
      :and_strip => "test@test.de ;test2@test.de\n| test3@test.de   "
    }.each do |name, value|
      it "should split recipients #{name}" do
        account = accounts(:biff_account)
        account.test_recipient_emails = value
        assert_equal %w(test@test.de test2@test.de test3@test.de), account.test_recipient_emails_array
      end
    end

  end

end