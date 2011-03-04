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
    end

    it "should not scheduled twice" do
      @newsletter.send_live!
      lambda do
        @newsletter.send_live!
      end.should raise_error
    end
  end

  describe "#update_only" do
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