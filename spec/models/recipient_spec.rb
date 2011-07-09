require 'spec_helper'

describe Recipient do
  fixtures :all

  context "#uniq" do
    let(:r) { recipients(:josh) }

    it "should have unique email per account" do
      new_r = r.account.recipients.new(:email => "unique@email.com")
      new_r.should be_valid
    end

    it "should have unique email per account" do
      new_r = r.account.recipients.new(:email => r.email)
      new_r.should_not be_valid
    end

    it "should have unique email per account" do
      account = accounts(:admin_account)
      new_r = account.recipients.new(:email => r.email)
      new_r.should be_valid
    end
  end

  context "#search" do
    it "should find exactly one" do
      account = accounts(:biff_account)
      recipient = account.recipients.first

      account.recipients.size.should > 1  #make sure we have more than one, otherwise rest of test is senseless ;-)

      Recipient::SEARCH_COLUMNS.each do |column|
        search_token = recipient.send(column)
        account.recipients.search(search_token).size.should == 1
        account.recipients.search(search_token[0..-2]).size.should == 1  #remove last char
        account.recipients.search(search_token[1..-1]).size.should == 1  #remove first char
      end
    end
  end

end

# == Schema Info
#
# Table name: recipients
#
#  id                       :integer(4)      not null, primary key
#  account_id               :integer(4)
#  bounced_deliveries_count :integer(4)      not null, default(0)
#  deliveries_count         :integer(4)      not null, default(0)
#  email                    :string(255)
#  failed_deliveries_count  :integer(4)      not null, default(0)
#  first_name               :string(255)
#  gender                   :string(255)
#  last_name                :string(255)
#  created_at               :datetime
#  updated_at               :datetime