require 'spec_helper'

describe Recipient do
  fixtures :all

  let(:recipient) { recipients(:josh) }

  context "#create" do
    context "state" do
      it "inits state with pending" do
        Recipient.create.state.should == 'pending'
      end
    end

    context "confirm code" do
      it "generates random string for code" do
        Recipient.create.confirm_code.should_not nil
      end

      it "does not mass assign code" do
        expect do
          Recipient.create(:confirm_code => 'custom')
        end.to raise_error
      end

      it "does not overwirte manual set confirm_code" do
        Recipient.new({:account => Account.first, :email => "test@test.com"}, :as => :test).tap do |recipient|
          recipient.confirm_code = 'custom'
          recipient.save!
          recipient.confirm_code.should == 'custom'
        end
      end

      it "generates uniqe one" do
        Recipient.new({:account => Account.first, :email => "test@test.com"}, :as => :test).tap do |recipient|
          recipient.confirm_code = Recipient.last.confirm_code
          recipient.save!
        end
      end
    end

    it "inital state is pending" do
      Recipient.create.state.should == 'pending'
    end

    it "inital state is pending" do
      expect do
        recipient.update_attributes( :first_name => 'wonne')
      end.to_not change { recipient.reload.confirm_code }.from(recipient.confirm_code)
    end
  end

  context "#uniq" do
    it "has unique email per account" do
      recipient.account.recipients.new(:email => "unique@email.com").should be_valid
    end

    it "has unique email per account" do
      recipient.account.recipients.new(:email => recipient.email).should_not be_valid
    end

    it "has unique email per account" do
      accounts(:admin_account).recipients.new(:email => recipient.email).should be_valid
    end
  end

  context "#search" do
    let(:account) { accounts(:biff_account) }
    let(:recipient) { account.recipients.first }

    it "finds exactly one" do
      account.recipients.size.should > 1  #make sure we have more than one, otherwise rest of test is senseless ;-)

      Recipient::SEARCH_COLUMNS.each do |column|
        search_token = recipient.send(column)
        account.recipients.search(search_token).size.should == 1
        account.recipients.search(search_token[0..-2]).size.should == 1  #remove last char
        account.recipients.search(search_token[1..-1]).size.should == 1  #remove first char
      end
    end
  end

  context "#delete" do
    %w(delete destroy delete!).each do |method|
      it "#{method} doesn't remove entry from DB" do
        expect do
          recipient.send(method)
        end.to_not change { Recipient.count }
      end
    end
  end

  describe "force_remove" do
    it "does remove entry from DB" do
      expect do
        recipient.force_destroy
      end.to change { Recipient.count }
    end

    it "does not remoce any send_outs" do
      recipient.live_send_outs.create(:newsletter => Newsletter.last)
      expect do
        recipient.force_destroy
      end.to_not change { SendOut.count }.from(1)
    end
  end
end

# == Schema Information
#
# Table name: recipients
#
#  id               :integer(4)      not null, primary key
#  gender           :string(255)
#  first_name       :string(255)
#  last_name        :string(255)
#  email            :string(255)
#  deliveries_count :integer(4)      default(0), not null
#  bounces_count    :integer(4)      default(0), not null
#  account_id       :integer(4)
#  created_at       :datetime
#  updated_at       :datetime
#  fails_count      :integer(4)      default(0), not null
#  confirm_code     :string(255)
#  state            :string(255)     default("pending")
#  reads_count      :integer(4)      default(0), not null
#
# Indexes
#
#  index_recipients_on_id_and_account_id  (id,account_id) UNIQUE
#  index_recipients_on_email              (email)
#  index_recipients_on_account_id         (account_id)
#

#  updated_at       :datetime
