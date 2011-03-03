require 'spec_helper'

describe Newsletter do
  fixtures :all

  describe "#with_account" do
    it "should find right newsletter" do
      @newsletter = newsletters(:biff_newsletter)

      assert_equal Newsletter.with_account(@newsletter.account).first, @newsletter
    end
  end

  describe "#update_only" do
  end

  # test "should " do
  #   @delivery = deliveries(:biff_sending)
  #
  #
  #   @newsletter.send(:update_only, :delivery_started_at)
  #   @newsletter.reload
  #   assert @newsletter.delivery_started_at != @newsletter.delivery_ended_at
  # end

end