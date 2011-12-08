require 'spec_helper'

describe Account do
  fixtures :all

  describe "#test_recipient_emails_array" do
    let(:account) { accounts(:admin_account) }

    {
      :by_comma => "test@test.de,test2@test.de,test3@test.de",
      :by_spec_char => "test@test.de;test2@test.de|test3@test.de",
      :uniq => "test@test.de,test2@test.de\r,test3@test.de,test3@test.de",
      :remove_empty => "test@test.de,,test2@test.de,test3@test.de,",
      :and_strip => "test@test.de ;test2@test.de\n| test3@test.de   "
    }.each do |name, value|
      it "splits recipients #{name}" do
        account.test_recipient_emails = value
        account.test_recipient_emails_array.should =~ %w(test@test.de test2@test.de test3@test.de)
      end
    end

    it "includes default test_emails" do
      $mail_config['test_recipient_emails'] = "test@test.de"
      account.test_recipient_emails_array.should =~ %w(test@test.de)
    end
  end

  describe "#process_bounces" do
    let(:account) { accounts(:biff_account) }

    it "doesn't fail" do
      account.should_receive(:mail_config).and_return(nil)
      account.process_bounces.should be_nil
    end
  end

end

# == Schema Info
#
# Table name: accounts
#
#  id                    :integer(4)      not null, primary key
#  user_id               :integer(4)
#  color                 :string(255)     default("#FFF")
#  from                  :string(255)
#  has_attachments       :boolean(1)
#  has_html              :boolean(1)      default(TRUE)
#  has_scheduling        :boolean(1)
#  has_text              :boolean(1)      default(TRUE)
#  mail_config_raw       :text
#  name                  :string(255)
#  subject               :string(255)
#  template_html         :text
#  template_text         :text
#  test_recipient_emails :text
#  created_at            :datetime
#  updated_at            :datetime