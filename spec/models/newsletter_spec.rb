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

        sending = @newsletter.send_live!

        sending.stub!(:after_start) do
          sending.send :send_to!, sending.recipients.first
          sending.stop!
        end

        sending.start!

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

    it "should return zero if no other sending exitst" do
      @newsletter.live_sendings.create!(:last_id => 42)
      @newsletter.last_id.should == 42
    end
  end




  # it "should deliver to live users" do
  #   count = @newsletter.recipients.count
  #
  #   @newsletter.send_live!
  #
  #   assert @newsletter.sending.is_a? LiveSending
  #
  #   assert_equal count, @newsletter.sending.oks
  #   assert_equal count, ActionMailer::Base.deliveries.size
  # end
  # test "should " do
  #   @delivery = deliveries(:biff_sending)
  #
  #
  #   @newsletter.send(:update_only, :delivery_started_at)
  #   @newsletter.reload
  #   assert @newsletter.delivery_started_at != @newsletter.delivery_ended_at
  # end

end