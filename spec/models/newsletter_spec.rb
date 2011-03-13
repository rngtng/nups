require 'spec_helper'

describe Newsletter do
  fixtures :all

  describe "#with_account" do
    it "should find right newsletter" do
      @newsletter = newsletters(:biff_newsletter)

      assert_equal Newsletter.with_account(@newsletter.account).first, @newsletter
    end
  end

  describe "#send" do
    before(:each) do
      @newsletter = newsletters(:biff_newsletter)
    end

    context "test" do
      it "should have users" do
        @newsletter.test_recipients.count.should == 2
      end

      it "should deliver to users" do
        expect do
          with_resque do
            @newsletter.send_test!
          end
        end.to change(ActionMailer::Base.deliveries, :size).by(2)
      end
    end

    context "live" do
      it "should have users" do
        @newsletter.recipients.count.should == 2
      end

      it "should deliver to users" do
        expect do
          with_resque do
            @newsletter.send_live!
          end
        end.to change(ActionMailer::Base.deliveries, :size).by(2)
      end

      it "should resume a stopped sending" do
        @newsletter = newsletters(:biff_newsletter)

        @newsletter.send_live!
        sending = @newsletter.sendings.first

        sending.stub!(:after_start) do
          sending.send :send_to!, sending.recipients.first
        end

        sending.start!
        @newsletter.stop!
        @newsletter.reload

        expect do
          with_resque do
            @newsletter.send_live!
          end
        end.to change(ActionMailer::Base.deliveries, :size).by(1)
      end
    end

    it "should not scheduled twice" do
      @newsletter.send_live!
      lambda do
        @newsletter.send_live!
      end.should raise_error
    end
  end

  describe "#last_id" do
    before(:each) do
      @newsletter = newsletters(:biff_newsletter)
    end

    it "should return zero if no other sending exitst" do
      @newsletter.last_id.should == 0
    end

    it "should not return id of last test sending" do
      @newsletter.test_sendings.create!(:last_id => 42)
      @newsletter.last_id.should == 0
    end

    it "should return id of last live sending" do
      @newsletter.live_sendings.create!(:last_id => 42)
      @newsletter.last_id.should == 42
    end
  end

end

# == Schema Info
#
# Table name: newsletters
#
#  id                  :integer(4)      not null, primary key
#  account_id          :integer(4)
#  last_sent_id        :integer(4)
#  content             :text
#  deliveries_count    :integer(4)      not null, default(0)
#  errors_count        :integer(4)      not null, default(0)
#  mode                :integer(4)      not null, default(0)
#  recipients_count    :integer(4)      not null, default(0)
#  status              :integer(4)      not null, default(0)
#  subject             :string(255)
#  created_at          :datetime
#  deliver_at          :datetime
#  delivery_ended_at   :datetime
#  delivery_started_at :datetime
#  updated_at          :datetime